// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Fluent
import Vapor
import Models
import JWT
import AuthServiceDTOs

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let authMiddleware = AuthMiddleware(payloadType: JWTPayloadDTO.self)
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
        authRoutes.get("email", "verify",":email", ":code", use: self.verifyEmail).openAPI(
            summary: "Verify email",
            description: "Verify email with code. HTML = without Query for Browser, API = Route/Email/Code?statusCodeResponse=true",
            response: .type(HTTPResponseStatus.self)
        )
        .response(statusCode: 204, description: "Email successfully verified")
        .response(statusCode: 400, description: "Bad Request. Invalid or missing email/code")
        .response(statusCode: 404, description: "Verification code not found")
        .response(statusCode: 409, description: "Conflict. Verification failed due to status being already failed")
        .response(statusCode: 410, description: "Gone. Verification code has expired")
        .response(statusCode: 208, description: "Already Reported")
        .response(statusCode: 500, description: "Internal Server Error")
        

        // geschützte Auth-Routen
        let protectedRoutes = authRoutes.grouped(authMiddleware)
        protectedRoutes.get("token-verify", use: self.verifyJWTToken).openAPI(
            summary: "Test given JWT-Token",
            description: "Test if JWT-Token is valid",
            response: .type(HTTPResponseStatus.self),
            auth: AuthMiddleware.schemeObject
        )
        
        protectedRoutes.get("token-test", use: self.tokenTest).openAPI(
            summary: "Get token payload",
            description: "Get payload infos",
            response: .type(JWTPayloadDTO.self),
            responseContentType: .application(.json),
            auth: AuthMiddleware.schemeObject
        )
        
        // Aktivieren des Accounts, durch den Admin => isActive wird auf true gesetzt
        protectedRoutes.put("activate-user", ":id", use: self.adminVerifyAccount).openAPI(
            summary: "Activate user account",
            description: "Activate user account with user id as admin",
            auth: AuthMiddleware.schemeObject
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
        guard let loginRequest = try? req.content.decode(UserLoginDTO.self) else {
            throw Abort(.badRequest, reason: "Request-Body does not match UserLoginDTO")
        }
        guard let loginEmail = loginRequest.email, let loginPassword = loginRequest.password else {
            throw Abort(.internalServerError, reason: "Cannot unwrap email and password")
        }
        guard let user = try await User.query(on: req.db)
            .with(\.$emailVerification)
            .filter(\.$email == loginEmail)
            .first() else {
            throw Abort(.notFound, reason: "Invalid credentials")
        }
        guard try Bcrypt.verify(loginPassword, created: user.passwordHash) else {
            throw Abort(.notFound, reason: "Invalid credentials")
        }
        
        guard user.emailVerification?.status == .verified else {
            throw Abort(.unauthorized, reason: "Email not verified")
        }
        
        // Hat der Nutzer einen aktiven Account
        guard user.isActive == true else {
            throw Abort(.forbidden, reason: "This account is inactiv")
        }
        let userIdNumber = try user.requireID()
        
        let expiration = Date().addingTimeInterval(3600) // Token für 1 Stunde gültig
        let payload = JWTPayloadDTO(userID: userIdNumber, exp: expiration, isAdmin: user.isAdmin)
        
        let token = try req.jwt.sign(payload, kid: "private")
        
        let tokenResponse = TokenResponseDTO(token: token)
        return tokenResponse
    }
    
    @Sendable
    func verifyJWTToken(req: Request) async throws -> HTTPResponseStatus {
        guard let token = req.headers.bearerAuthorization?.token ?? req.cookies["token"]?.string else {
            req.logger.warning("No Token found in Authorization header or cookies")
            return .unauthorized
        }
        do {
            _ = try req.jwt.verify(token, as: JWTPayloadDTO.self)
            return .ok
        } catch {
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
        try await user.update(on: req.db)
        
        return Response(status: .ok, body: .init(string: "User account has been successfully activated"))
    }
    
    @Sendable
    func verifyEmail(req: Request) async throws -> Response {
        var statusCodeResponse = false
        
        if let param = req.query[Bool.self, at: "statusCodeResponse"] {
            statusCodeResponse = param
        }
            
        guard let code = req.parameters.get("code", as: String.self) else {
            throw Abort(.badRequest, reason: "Missing code")
        }
        
        guard let email = req.parameters.get("email", as: String.self) else {
            throw Abort(.badRequest, reason: "Missing email")
        }
                
        guard let verification = try await EmailVerification.find(email, on: req.db) else {
            if statusCodeResponse == true {
                return Response(status: .notFound)
            } else {
                return req.fileio.streamFile(at: "Resources/Views/emailVerificationFailed.html")
            }
        }
        
        guard verification.status == .pending else {
            if verification.status == .failed {
                if statusCodeResponse == true {
                    return Response(status: .conflict)
                } else {
                    return req.fileio.streamFile(at: "Resources/Views/emailVerificationFailed.html")
                }
            }
            if verification.status == .verified {
                if statusCodeResponse == true {
                    return Response(status: .alreadyReported)
                } else {
                    return req.fileio.streamFile(at: "Resources/Views/emailVerificationVerified.html")
                }
            }
            throw Abort(.internalServerError)
        }
        
        guard let expiresAt = verification.expiresAt, expiresAt > Date() else {
            if statusCodeResponse == true {
                return Response(status: .gone)
            }
            return req.fileio.streamFile(at: "Resources/Views/emailVerificationFailed.html")
        }
        
        guard verification.code == code else {
            verification.status = .failed
            try await verification.update(on: req.db)
            if statusCodeResponse == true {
                return Response(status: .notFound)
            } else {
                return req.fileio.streamFile(at: "Resources/Views/emailVerificationFailed.html")
            }
        }
            
        verification.status = .verified
        verification.verifiedAt = Date()
        
        try await verification.update(on: req.db)
        
        if statusCodeResponse == true {
            return Response(status: .noContent)
        } else {
            return req.fileio.streamFile(at: "Resources/Views/emailVerificationSuccess.html")
        }
    }
}
