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
        authRoutes.post("login", use: self.login)
        // geschützte Auth-Routen
        let protectedRoutes = authRoutes.grouped(authMiddleware)
        protectedRoutes.get("token-verify", use: self.verifyJWTToken)
        protectedRoutes.get("token-test", use: self.tokenTest)
    }
    
    @Sendable
    func tokenTest(req: Request) async throws -> String {
        guard let payload = req.jwtPayload else {
            throw Abort(.unauthorized)
        }
        let userID: UUID = payload.userID!
        let exp: ExpirationClaim = payload.exp
        let isAdmin: Bool = payload.isAdmin!
        return "User ID: \(userID), Exp: \(exp), isAdmin: \(isAdmin)"
    }
    
    @Sendable
    func login(req: Request) async throws -> TokenResponseDTO {
        let loginRequest = try req.content.decode(UserLoginDTO.self)
        
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == loginRequest.email!)
            .filter(\.$isActive == true)
            .first() else {
                throw Abort(.unauthorized, reason: "Invalid credentials")
        }
        guard try Bcrypt.verify(loginRequest.password!, created: user.passwordHash) else {
            throw Abort(.unauthorized, reason: "Invalid credentials")
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
}
