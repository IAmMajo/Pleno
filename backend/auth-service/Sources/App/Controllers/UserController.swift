import Fluent
import Vapor
import Models
import JWT

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userRoutes = routes.grouped("users")
        
        userRoutes.post("register", use: self.register)
        userRoutes.get("profile", use: self.getProfile)
        userRoutes.put("profile", use: self.updateProfile)
        
        let jwtSigner = JWTSigner.hs256(key: "Ganzgeheimespasswort")
        let authMiddleware = AuthMiddleware(jwtSigner: jwtSigner, payloadType: JWTPayloadDTO.self)
        let protectedRoutes = userRoutes.grouped(authMiddleware)
        
        // GET /users -> alle User
        protectedRoutes.get(use: self.getAllUsers)
        // GET /users/:id -> ein User
        protectedRoutes.get(":id", use: self.getUser)
        // GET /users/identities/:id
        protectedRoutes.get("identities", ":id", use: self.getIdentities)
        // PATCH /users/:id
        protectedRoutes.patch(":id", use: self.updateUserStatus)
        // DELETE /users/:id
        protectedRoutes.delete(":id", use: self.deleteUser)
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
    
    @Sendable
    func getAllUsers(req: Request) async throws -> [UserProfileDTO] {
        // Prüft ob ein Token vorhanden ist
        guard let payload = req.jwtPayload else {
            throw Abort(.unauthorized)
        }
        // Prüft den Token auf Admin
        guard payload.isAdmin == true else {
            throw Abort(.forbidden, reason: "User is not an admin")
        }
        
        let users = try await User.query(on: req.db)
            .with(\.$identity)
            .all()
        return users.map { user in
            UserProfileDTO(
                uid: user.id,
                email: user.email,
                name: user.identity.name,
                isAdmin: user.isAdmin,
                isActive: user.isActive,
                createdAt: user.createdAt
            )
        }
    }
    
    @Sendable
    func getUser(req: Request) async throws -> UserProfileDTO {
        // Prüft auf Token
        guard let payload = req.jwtPayload else {
            throw Abort(.unauthorized)
        }
        //Prüft auf Admin
        guard payload.isAdmin == true else {
            throw Abort(.forbidden, reason: "User is not an admin")
        }
        //Speichert übergebene userID
        guard let userID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing user ID")
        }
        // Sucht User
        guard let user = try await User.query(on: req.db)
            .filter(\.$id == userID)
            .with(\.$identity)
            .first() else {
            throw Abort(.notFound, reason: "User not found")
        }
        // Gibt ProfilDTO zurück
        return UserProfileDTO(
            uid: user.id,
            email: user.email,
            name: user.identity.name,
            isAdmin: user.isAdmin,
            isActive: user.isActive,
            createdAt: user.createdAt
        )
    }
    
    @Sendable
    func getIdentities(req: Request) async throws -> [Identity] {
        guard let payload = req.jwtPayload else {
            throw Abort(.unauthorized)
        }
        guard payload.isAdmin == true else {
            throw Abort(.forbidden, reason: "User is not an admin")
        }
        guard let userID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing user ID")
        }
        let identities = try await Identity.query(on: req.db)
            .join(IdentityHistory.self, on: \Identity.$id == \IdentityHistory.$identity.$id)
            .filter(IdentityHistory.self, \.$user.$id == userID)
            .all()
        
        guard !identities.isEmpty else {
            throw Abort(.notFound, reason: "No identities found for user")
        }
        return identities
    }
    
    @Sendable
    func updateUserStatus(req: Request) async throws -> HTTPResponseStatus {
        guard let payload = req.jwtPayload else {
            throw Abort(.unauthorized)
        }
        guard payload.isAdmin == true else {
            throw Abort(.forbidden, reason: "User is not an admin")
        }
        guard let userID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing user ID")
        }
        let update = try req.content.decode(UserProfileUpdateDTO.self)
        
        guard let user = try await User.query(on: req.db)
            .filter(\.$id == userID)
            .first() else {
            throw Abort(.notFound, reason: "User not found")
        }
        if let isActive = update.isActive {
            user.isActive = isActive
        }
        if let isAdmin = update.isAdmin {
            user.isAdmin = isAdmin
        }
        
        try await user.save(on: req.db)
        
        return .ok
    }
    
    @Sendable
    func deleteUser(req: Request) async throws -> HTTPResponseStatus {
        guard let payload = req.jwtPayload else {
            throw Abort(.unauthorized)
        }
        guard payload.isAdmin == true else {
            throw Abort(.forbidden, reason: "User is not an admin")
        }
        guard let userID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing user ID")
        }
        guard let user = try await User.query(on: req.db)
            .filter(\.$id == userID)
            .first() else {
            throw Abort(.notFound, reason: "User not found")
        }
        let identityHistories = try await IdentityHistory.query(on: req.db)
            .filter(\.$user.$id == userID)
            .all()
        
        for identityHistory in identityHistories {
            identityHistory.$user.id = nil
            try await identityHistory.save(on: req.db)
        }
        
        try await user.delete(on: req.db)
        
        return .noContent
    }
}
