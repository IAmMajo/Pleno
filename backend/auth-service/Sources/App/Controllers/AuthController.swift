import Fluent
import Vapor
import Models

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let authRoutes = routes.grouped("auth");
        authRoutes.post("login", use: self.login)
        
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
}
