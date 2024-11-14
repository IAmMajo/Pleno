import Fluent
import Vapor
import Models

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userRoutes = routes.grouped("users")
        
        userRoutes.post("register", use: self.register)
        userRoutes.get("profile", use: self.getProfile)
        userRoutes.put("profile", use: self.updateProfile)
    }
    
    @Sendable
    func updateProfile(req: Request) async throws -> HTTPStatus {
        // parse and verify jwt token
        let token = try req.jwt.verify(as: JWTPayloadDTO.self)

        // decode updates
        let update = try req.content.decode(UserProfileUpdateDTO.self)
        
        // query user
        guard let user = try await User.query(on: req.db)
            .filter(\.$id == token.userID!)
            .with(\.$identity)
            .first() else {
            throw Abort(.notFound)
        }
        
        // clone identity
        let updatedIdentity = user.identity.clone()
        
        // update identity
        updatedIdentity.name = update.name!
        
        // save updated identity
        try await updatedIdentity.save(on: req.db)
        
        // extract identity id
        let identityID = try updatedIdentity.requireID()
        
        // update current identity
        user.$identity.id = identityID
        
        // save update
        try await user.update(on: req.db)
        
        // extract identity id
        let userID = try user.requireID()
        
        // create history object
        let history = IdentityHistory(userID: userID, identityID: identityID)
        
        // save history entry
        try await history.save(on: req.db)
        
        return .ok
    }
    
    @Sendable
    func getProfile(req: Request) async throws -> UserProfileDTO {
        // parse and verify jwt token
        let token = try req.jwt.verify(as: JWTPayloadDTO.self)
        
        // query user
        guard let user = try await User.query(on: req.db)
            .filter(\.$id == token.userID!)
            .with(\.$identity)
            .first() else {
            throw Abort(.notFound)
        }
        
        // build reponse object
        var response = UserProfileDTO()
        response.email = user.email
        response.isAdmin = user.isAdmin
        response.createdAt = user.createdAt
        response.name = user.identity.name
        
        return response
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
