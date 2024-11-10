import Fluent
import Vapor
import Models

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userRoutes = routes.grouped("users")
        
        userRoutes.post("register", use: self.register)
        
    }
    
    @Sendable
    func register(req: Request) async throws -> HTTPStatus {
        // validate content
        try UserRegistrationDTO.validate(content: req)
        
        // parse registration data
        let registration_data = try req.content.decode(UserRegistrationDTO.self)
        
        // check for user with same email
        let count = try await User.query(on: req.db).filter(\.$email == registration_data.email!).count()
        if count != 0 {
            throw Abort(.conflict, reason: "a user with this email already exists")
        }
        
        // create new identity
        let identity = Identity(name: registration_data.name!)
        
        // save identity in database
        try await identity.save(on: req.db)
        
        // hash password
        let passwordHash = try req.password.hash(registration_data.password!)
        
        // extract identity id
        let identityID = try identity.requireID()
        
        // create new user
        let user = User(identityID: identityID, email: registration_data.email!, passwordHash: passwordHash)
        
        // the first user becomes admin
        let countAll = try await User.query(on: req.db).count()
        if countAll == 0 {
            user.isAdmin = true
        }
        
        // save user in database
        try await user.save(on: req.db)
        
        // extract identity id
        let userID = try user.requireID()
        
        // create history object
        let history = IdentityHistory(userID: userID, identityID: identityID)
        
        // save history entry
        try await history.save(on: req.db)
        
        return .ok
    }
}
