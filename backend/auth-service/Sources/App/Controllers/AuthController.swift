import Fluent
import Vapor
import Models
import JWT

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let jwtSigner = JWTSigner.hs256(key: "Ganzgeheimespasswort")
        let authMiddleware = AuthMiddleware(jwtSigner: jwtSigner, payloadType: JWTPayloadDTO.self)
        // Auth-Routen
        let authRoutes = routes.grouped("auth");
        authRoutes.post("login", use: self.login).openAPI(
            summary: "User login",
            description: "App login with user credentials",
            body: .type(UserLoginDTO.self),
            contentType: .application(.json),
            response: .type(TokenResponseDTO.self),
            responseContentType: .application(.json)
        )
        
        //Email Verifizieren
        authRoutes.get("email", "verify", ":code", use: self.verifyEmail).openAPI(
            summary: "Verify email",
            description: "Verify email with code"
        )

        // geschützte Auth-Routen
        let protectedRoutes = authRoutes.grouped(authMiddleware)
        protectedRoutes.get("token-verify", use: self.verifyJWTToken).openAPI(
            summary: "Test given JWT-Token",
            description: "Test if JWT-Token is valid",
            response: .type(HTTPResponseStatus.self),
            auth: .bearer()
        )
        
        protectedRoutes.get("token-test", use: self.tokenTest).openAPI(
            summary: "Get token payload",
            description: "Get payload infos",
            response: .type(JWTPayloadDTO.self),
            responseContentType: .application(.json),
            auth: .bearer()
        )
        
        // Auflisten aller Accounts mit jeweiligem Email-Verifizierungs-Status
        protectedRoutes.get("users", use: self.adminListAllVerifications).openAPI(
            summary: "Admin list all users with verification status",
            description: "Verification status",
            response: .type(UserEmailVerificationDTO.self),
            responseContentType: .application(.json),
            auth: .bearer()
        )
        
        // Aktivieren des Accounts, durch den Admin => isActive wird auf true gesetzt
        protectedRoutes.patch("activate-user", ":id", use: self.adminVerifyAccount).openAPI(
            summary: "Activate user account",
            description: "Activate user account with user id as admin",
            auth: .bearer()
        )
    }
    
    @Sendable
    func tokenTest(req: Request) async throws -> JWTPayloadDTO {
        guard let payload = req.jwtPayload else {
            throw Abort(.unauthorized)
        }
        return JWTPayloadDTO(
            userID: payload.userID,
            exp: payload.exp.value,
            isAdmin: payload.isAdmin
        )
    }
    
    @Sendable
    func login(req: Request) async throws -> TokenResponseDTO {
        let loginRequest = try req.content.decode(UserLoginDTO.self)
        
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == loginRequest.email!)
            .first() else {
                throw Abort(.unauthorized, reason: "Invalid credentials")
        }
        guard try Bcrypt.verify(loginRequest.password!, created: user.passwordHash) else {
            throw Abort(.unauthorized, reason: "Invalid credentials")
        }
        
        guard user.isActive == true else {
            throw Abort(.unauthorized, reason: "This account is inactiv")
        }
        
        let expiration = Date().addingTimeInterval(3600) // Token für 1 Stunde gültig
        let payload = JWTPayloadDTO(userID: user.id!, exp: expiration, isAdmin: user.isAdmin)
        
        let token = try req.jwt.sign(payload)
        
        let tokenResponse = TokenResponseDTO(token: token)
        return tokenResponse
    }
    
    @Sendable
    func verifyJWTToken(req: Request) async throws -> HTTPResponseStatus {
        let jwtSigner = JWTSigner.hs256(key: "Ganzgeheimespasswort")
        
        guard let token = req.headers.bearerAuthorization?.token ?? req.cookies["token"]?.string else {
            req.logger.warning("No Token found in Authorization header or cookies")
            return .unauthorized
        }
        
        do {
            let payload = try jwtSigner.verify(token, as: JWTPayloadDTO.self)
            
            req.logger.info("Token verified successfully for user \(payload.userID!)")
            return .ok
        } catch {
            req.logger.error("Token verification failed: \(error)")
            
            if let jwtError = error as? JWTError, case .claimVerificationFailure(_,_) = jwtError {
                return .forbidden
            } else {
                return .internalServerError
            }
        }
    }
    
    @Sendable
    func adminVerifyAccount(req: Request) async throws -> Response {
        guard let payload = req.jwtPayload else {
            throw Abort(.unauthorized)
        }
        guard payload.isAdmin == true else {
            throw Abort(.forbidden, reason: "User is not an admin")
        }
        guard let userID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing user ID")
        }
        guard let user = try await User.find(userID, on: req.db)  else {
            throw Abort(.notFound, reason: "User not found")
        }
        
        guard let emailVerification =  try await user.$emailVerification.get(on: req.db),
              emailVerification.status == .verified else {
            throw Abort(.badRequest, reason: "User's email has not been verified")
        }
        
        user.isActive = true
        try await user.save(on: req.db)
        
        return Response(status: .ok, body: .init(string: "User account has been successfully activated"))
    }
    
    @Sendable
    func adminListAllVerifications(req: Request) async throws -> [UserEmailVerificationDTO] {
        guard let payload = req.jwtPayload else {
            throw Abort(.unauthorized)
        }
        guard payload.isAdmin == true else {
            throw Abort(.forbidden, reason: "User is not an admin")
        }
        let users = try await User.query(on: req.db)
            .with(\.$identity)
            .join(EmailVerification.self, on: \User.$id == \EmailVerification.$user.$id)
            .all()
        
        let responseData = try users.map { user in
            let emailVerification = try user.joined(EmailVerification.self)
            
            return UserEmailVerificationDTO(
                uid: user.id,
                name: user.identity.name,
                isActive: user.isActive,
                emailStatus: VerificationStatus(rawValue: emailVerification.status.rawValue),
                createdAt: user.createdAt
            )
        }
        return responseData
    }
    
    @Sendable
    func verifyEmail(req: Request) async throws -> Response {
        guard let code = req.parameters.get("code", as: String.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing code")
        }
        guard let verification = try await EmailVerification.query(on: req.db)
            .filter(\.$code == code)
            .first() else {
            return req.fileio.streamFile(at: "Resources/Views/emailVerificationFailed.html")
        }
        guard verification.status == .pending else {
            return req.fileio.streamFile(at: "Resources/Views/emailVerificationVerified.html")
        }
        if let expiresAt = verification.expiresAt, expiresAt < Date() {
            return req.fileio.streamFile(at: "Resources/Views/emailVerificationFailed.html")
        }
        verification.status = .verified
        verification.verifiedAt = Date()
        
        try await verification.save(on: req.db)
        
        return req.fileio.streamFile(at: "Resources/Views/emailVerificationSuccess.html")
    }
}
