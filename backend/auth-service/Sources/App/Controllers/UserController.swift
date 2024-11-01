import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userRoutes = routes.grouped("users")
        
        userRoutes.post("register", use: self.register)
        
    }
    
    @Sendable
    func register(req: Request) async throws -> HTTPStatus {
        // validate content
        try User.validate(content: req)
        
        // convert data to model
        let user = try req.content.decode(UserDTO.self).toModel()
        
        // hash password
        user.passwordHash = try req.password.hash(user.passwordHash)
        
        // set defaults
        user.isActive = false
        user.role = ""
        
        // save model in database
        try await user.save(on: req.db)
        
        return .ok
    }
}
