import Fluent
import Vapor
import Models
import JWT
import NotificationsServiceDTOs

extension SendEmailDTO: @retroactive AsyncResponseEncodable {}
extension SendEmailDTO: @retroactive AsyncRequestDecodable {}
extension SendEmailDTO: @retroactive ResponseEncodable {}
extension SendEmailDTO: @retroactive RequestDecodable {}
extension SendEmailDTO: @retroactive Content, @unchecked @retroactive Sendable {}

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userRoutes = routes.grouped("users")
        
        userRoutes.put("password", "reset-request", use: self.requestPasswordReset).openAPI(
            summary: "Request Reset Code",
            description: "Request Reset Code with Email",
            body: .type(RequestPasswordResetDTO.self)
        )
        userRoutes.put("password", "reset", use: self.userResetPasswort).openAPI(
            summary: "Reset Password with code",
            description: "Reset Password with email, code and new password",
            body: .type(ResetPasswordDTO.self)
        )
        
        let jwtSigner = JWTSigner.hs256(key: "Ganzgeheimespasswort")
        let authMiddleware = AuthMiddleware(jwtSigner: jwtSigner, payloadType: JWTPayloadDTO.self)
        let protectedRoutes = userRoutes.grouped(authMiddleware)
        
        userRoutes.on(.POST, "register", body: .collect(maxSize: "7000kb"), use: self.register).openAPI(
            summary: "Register an account",
            description: "Register an account to new Members",
            body: .type(UserRegistrationDTO.self),
            contentType: .application(.json),
            response: .type(UserRegistrationDTO.self)
        )
        userRoutes.put("email", "resend", ":email", use: self.resendVerificationEmail).openAPI(
            summary: "Resend verification email",
            description: "Resend pending verification link",
            contentType: .application(.json)
        )
        
        userRoutes.get("profile", use: self.getProfile).openAPI(
            summary: "Get profile",
            description: "Get current profile of user",
            body: .none,
            response: .type(UserProfileDTO.self),
            responseContentType: .application(.json),
            auth: .bearer()
        )
        protectedRoutes.on(.PATCH, "profile", body: .collect(maxSize: "7000kb"), use: self.updateProfile).openAPI(
            summary: "Update profile",
            description: "Update identity and/or profileImage",
            body: .type(UserProfileUpdateDTO.self),
            response: .type(HTTPResponseStatus.self),
            auth: .bearer()
        )
        
        
        // GET /users -> alle User
        protectedRoutes.get(use: self.getAllUsers).openAPI(
            summary: "Admin get all users",
            description: "List all user profiles",
            body: .none,
            response: .type(UserProfileDTO.self),
            responseContentType: .application(.json),
            auth: .bearer()
            
        )
        // GET /users/:id -> ein User
        protectedRoutes.get(":id", use: self.getUser).openAPI(
            summary: "Admin get a user profile",
            description: "Get User with user id",
            body: .none,
            response: .type(UserProfileDTO.self),
            responseContentType: .application(.json),
            auth: .bearer()
            
            
        )
        // GET /users/identities/:id
        protectedRoutes.get("identities", ":id", use: self.getIdentities).openAPI(
            summary: "Admin get all user identites",
            description: "Get all identites with user id",
            response: .type(Identity.self),
            responseContentType: .application(.json),
            auth: .bearer()
            
        )
        // PATCH /users/:id
        protectedRoutes.patch(":id", use: self.updateUserStatus).openAPI(
            summary: "Patch isActive or isAdmin",
            description: "Admin Patch user profile status",
            body: .type(UserUpdateAccountDTO.self),
            contentType: .application(.json),
            response: .type(HTTPResponseStatus.self),
            auth: .bearer()
            
        )
        // DELETE /users/:id
        protectedRoutes.delete(":id", use: self.deleteUser).openAPI(
            summary: "Admin delete user account",
            description: "Admin can delete user account with user id",
            response: .type(HTTPResponseStatus.self),
            auth: .bearer()
            
        )
        // GET /users/profile-image/identity/:identity_id
        protectedRoutes.get("profile-image", "identity", ":id", use: self.getImageIdentity).openAPI(
            summary: "Get profile image",
            description: "Get profile image with identity id",
            responseContentType: .application(.json),
            auth: .bearer()
            
        )
        // GET /users/profile-image/user/:user_id
        protectedRoutes.get("profile-image", "user", ":id", use: self.getImageUser).openAPI(
            summary: "Get profile image",
            description: "Get profile image with user id",
            responseContentType: .application(.json),
            auth: .bearer()
            
            
        )
        // GET /users/identities
        protectedRoutes.get("identities", use: self.userGetIdentities).openAPI(
            summary: "Get identities",
            description: "Get own identities with JWT-Token",
            response: .type(Identity.self),
            responseContentType: .application(.json),
            auth: .bearer()
            
        )
        // DELETE /users/delete
        protectedRoutes.delete("delete", use: self.userDeleteEntry).openAPI(
            summary: "Delete user account",
            description: "Delete own user account with JWT-Token",
            response: .type(HTTPResponseStatus.self),
            responseContentType: .application(.json),
            auth: .bearer()
        )
        // PATCH /users/change-password
        protectedRoutes.patch("change-password", use: self.userChangePassword).openAPI(
            summary: "Change password",
            description: "Change password with old password",
            body: .type(ChangePasswordDTO.self),
            contentType: .application(.json)
        )
    }
    
    @Sendable
    func updateProfile(req: Request) async throws -> HTTPStatus {
        // parse and verify jwt token
        let token = try req.jwt.verify(as: JWTPayloadDTO.self)
        
        // decode updates
        let update = try req.content.decode(UserProfileUpdateDTO.self)
        
        /// **Verbesserungsvorschlag**:
        guard let userID = token.userID, let user = try await User.find(userID, on: req.db) else {
            throw Abort(.unauthorized)
        }
        let oldIdentity = try await user.$identity.get(on: req.db)
        let updatedIdentity = oldIdentity.clone()
        
        /// **Alte Version**
        //        // query user
        //        guard let user = try await User.query(on: req.db)
        //            .filter(\.$id == token.userID!)
        //            .with(\.$identity)
        //            .first() else {
        //            throw Abort(.notFound)
        //        }
        //
        //        // clone identity
        //        let updatedIdentity = user.identity.clone()
        
        if let newName = update.name {
            updatedIdentity.name = newName
        }
        let newAttendancesContainer: ContainerActor<[Attendance]> = .init(value: [])
        try await req.db.transaction { db in
            if let newProfileImage = update.profileImage {
                user.profileImage = newProfileImage
            }
            
            if updatedIdentity.hasChanges {
                try await updatedIdentity.create(on: db)
                let identityID = try updatedIdentity.requireID()
                
                // update current identity
                user.$identity.id = identityID
                // create history object
                try await IdentityHistory(userID: user.requireID(), identityID: identityID).create(on: db)
                
                // save update
                try await user.update(on: db)
                
                // Update corresponding attendance entries or bubble up failure
                let response = try await req.client.put("http://meeting-service/internal/adjust-identities/prepare/\(oldIdentity.requireID().uuidString)/\(identityID.uuidString)")
                    .throwOnVaporError()
                guard response.status == .ok else {
                    throw Abort(response.status) // Should never be necessary (except for wrong response status definitions)
                }
                guard let newAttendances = try? response.content.decode([Attendance].self) else {
                    throw Abort(.internalServerError, reason: "Could not decode response.")
                }
                await newAttendancesContainer.setValue(newAttendances)
            } else if (user.hasChanges) {
                // save update
                try await user.update(on: db)
            } else {
                throw Abort(.conflict, reason: "No changes were made.")
            }
        }
        
        let newAttendances = await newAttendancesContainer.value
        if !newAttendances.isEmpty {
            do {
                let response = try await req.client.put("http://meeting-service/internal/adjust-identities") { request in
                    try request.content.encode(newAttendances)
                }
                    .throwOnVaporError()
                guard response.status == .noContent else {
                    throw Abort(response.status) // Should never be necessary (except for wrong response status definitions)
                }
            } catch { 
                return .multiStatus
            }
        }
        
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
        response.uid = user.id
        response.email = user.email
        response.isAdmin = user.isAdmin
        response.isActive = user.isActive
        response.createdAt = user.createdAt
        response.name = user.identity.name
        response.profileImage = user.profileImage
        
        return response
    }
    
    @Sendable
    func register(req: Request) async throws -> Response {
        // validate content
        try UserRegistrationDTO.validate(content: req)
        
        // parse registration data
        let registrationData = try req.content.decode(UserRegistrationDTO.self)
        
        // check for user with same email
        let count = try await User.query(on: req.db).filter(\.$email == registrationData.email!).count()
        if count != 0 {
            throw Abort(.conflict, reason: "a user with this email already exists")
        }
        
        let profileImageData: Data?
        if let profileImage = registrationData.profileImage {
            profileImageData = profileImage
        } else {
            profileImageData = nil
        }
        
        // create new identity
        let identity = Identity(name: registrationData.name!)
        
        // save identity in database
        try await identity.save(on: req.db)
        
        // hash password
        let passwordHash = try req.password.hash(registrationData.password!)
        
        // extract identity id
        let identityID = try identity.requireID()
        
        // create new user
        let user = User(identityID: identityID, email: registrationData.email!, passwordHash: passwordHash, profileImage: profileImageData)
        
        // the first user becomes admin and instant access
        let countAll = try await User.query(on: req.db).count()
        if countAll == 0 {
            user.isAdmin = true
            user.isActive = true
        }
        
        // save user in database
        try await user.save(on: req.db)
        
        // extract identity id
        let userID = try user.requireID()
        
        // create history object
        let history = IdentityHistory(userID: userID, identityID: identityID)
        
        // save history entry
        try await history.save(on: req.db)
        
        let registeredUser = UserProfileDTO(
            uid: user.id,
            email: user.email,
            name: identity.name,
            profileImage: user.profileImage,
            isAdmin: user.isAdmin,
            isActive: user.isActive,
            createdAt: user.createdAt
        )
        
        let verificationCode = String(format: "%06d", Int.random(in: 0...999999))
        
        let emailVerification = EmailVerification(
            user: user.id!,
            email: user.email,
            code: verificationCode,
            status: .pending,
            expiresAt: Date().addingTimeInterval(3600)
        )
            
        try await emailVerification.save(on: req.db)
        
        let verifyLink = "https://kivop.ipv64.net/auth/email/verify/\(verificationCode)"
        
        let emailData = SendEmailDTO(
            receiver: user.email,
            subject: "Email-Verifizierung",
            message: "Verifizierungslink: \(verifyLink)"
        )
        
        let response = try await req.client.post("https://kivop.ipv64.net/email") { request in
            try request.content.encode(emailData)
        }
        
        guard response.status == .ok else {
            throw Abort(.internalServerError, reason: "Failed to send email: \(response.status)")
        }
        
        return try await registeredUser.encodeResponse(status: .created, for: req)
    }
    
    @Sendable
    func resendVerificationEmail(req: Request) async throws -> Response {
        guard let email = req.parameters.get("email", as: String.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing email")
        }
        
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == email)
            .first() else {
            throw Abort(.notFound, reason: "No user found with the given email")
        }
        
        guard let emailVerification = try await user.$emailVerification.get(on: req.db),
              emailVerification.status == .pending else {
            throw Abort(.badRequest, reason: "User's email has already been verified")
        }
        
        if emailVerification.expiresAt! < Date() {
            let newVerificationCode = String(format: "%06d", Int.random(in: 0...999999))
            
            emailVerification.code = newVerificationCode
            emailVerification.expiresAt = Date().addingTimeInterval(3600)
            
            try await emailVerification.save(on: req.db)
            
            let verifyLink = "https://kivop.ipv64.net/auth/email/verify/\(newVerificationCode)"
            
            let emailData = SendEmailDTO(
                receiver: user.email,
                subject: "Email-Verifizierung",
                message: "Verifizierungslink: \(verifyLink)"
            )
            
            let response = try await req.client.post("https://kivop.ipv64.net/email") { request in
                try request.content.encode(emailData)
            }
            
            guard response.status == .ok else {
                throw Abort(.internalServerError, reason: "Failed to send email: \(response.status)")
            }
            return Response(status: .ok, body: .init(string: "A new verification email has been sent"))
        } else {

            let verifyLink = "https://kivop.ipv64.net/auth/email/verify/\(emailVerification.code)"
            
            let emailData = SendEmailDTO(
                receiver: user.email,
                subject: "Email-Verifizierung",
                message: "Verifizierungslink: \(verifyLink)"
            )
            
            let response = try await req.client.post("https://kivop.ipv64.net/email") { request in
                try request.content.encode(emailData)
            }
            
            guard response.status == .ok else {
                throw Abort(.internalServerError, reason: "Failed to send email: \(response.status)")
            }
            return Response(status: .ok, body: .init(string: "A new verification email has been sent"))
        }
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
            .with(\.$emailVerification)
            .all()
        var userProfiles: [UserProfileDTO] = []
        
        for user in users {
            let profileDTO = UserProfileDTO(
                uid: user.id,
                email: user.email,
                name: user.identity.name,
                profileImage: user.profileImage,
                isAdmin: user.isAdmin,
                isActive: user.isActive,
                emailVerification: VerificationStatus(rawValue: user.emailVerification!.status.rawValue),
                createdAt: user.createdAt
            )
            userProfiles.append(profileDTO)
        }
        return userProfiles
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
            .with(\.$emailVerification)
            .first() else {
            throw Abort(.notFound, reason: "User not found")
        }
    
        // Gibt ProfilDTO zurück
        return UserProfileDTO(
            uid: user.id,
            email: user.email,
            name: user.identity.name,
            profileImage: user.profileImage,
            isAdmin: user.isAdmin,
            isActive: user.isActive,
            emailVerification: VerificationStatus(rawValue: user.emailVerification!.status.rawValue),
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
        let identityHistories = try await IdentityHistory.query(on: req.db)
            .with(\.$identity)
            .filter(\.$user.$id == userID)
            .all()
        
        guard !identityHistories.isEmpty else {
            throw Abort(.notFound, reason: "No identities found for user")
        }
        
        let identities = identityHistories.map { history in
            Identity(
                id: history.id,
                name: history.identity.name
            )
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
        let update = try req.content.decode(UserUpdateAccountDTO.self)
        
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
    
    @Sendable
    func getImageIdentity(req: Request) async throws -> Response {
        guard let identityId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing identity ID")
        }
        guard let identity = try await Identity.query(on: req.db)
            .filter(\.$id == identityId)
            .first() else {
            throw Abort(.notFound, reason: "Identity not found")
        }
        guard let user = try await User.query(on: req.db)
            .filter(\.$identity.$id == identity.id!)
            .first() else {
            throw Abort(.notFound, reason: "User not found")
        }
        return Response(status: .ok, body: .init(data: user.profileImage ?? Data()))
    }
    
    @Sendable
    func getImageUser(req: Request) async throws -> Response {
        guard let userId = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing user ID")
        }
        guard let user = try await User.query(on: req.db)
            .filter(\.$id == userId)
            .first() else {
            throw Abort(.notFound, reason: "User not found")
        }
        return Response(status: .ok, body: .init(data: user.profileImage ?? Data()))
    }
    
    @Sendable
    func userGetIdentities(req: Request) async throws -> [Identity] {
        guard let payload = req.jwtPayload else {
            throw Abort(.unauthorized)
        }
        let identityHistories = try await IdentityHistory.query(on: req.db)
            .with(\.$identity)
            .filter(\.$user.$id == payload.userID)
            .all()
        
        guard !identityHistories.isEmpty else {
            throw Abort(.notFound, reason: "No identities found for user")
        }
        
        let identities = identityHistories.map { history in
            Identity(
                id: history.id,
                name: history.identity.name
            )
        }
        return identities
    }
    
    @Sendable
    func userDeleteEntry(req: Request) async throws -> Response {
        guard let payload = req.jwtPayload else {
            throw Abort(.unauthorized)
        }
        guard let user = try await User.query(on: req.db)
            .filter(\.$id == payload.userID!)
            .first() else {
            throw Abort(.notFound, reason: "User not found")
        }
        if user.isAdmin {
            let adminCount = try await User.query(on: req.db)
                .filter(\.$isAdmin == true)
                .count()
            if adminCount <= 1 {
                throw Abort(.forbidden, reason: "Cannot delete the last admin user")
            }
        }
        do {
            try await user.delete(on: req.db)
            return Response(status: .noContent)
        } catch {
            throw Abort(.internalServerError, reason: "Error deleting user: \(error.localizedDescription)")
        }
    }
     
    @Sendable
    func userChangePassword(req: Request) async throws -> Response {
        guard let payload = req.jwtPayload else {
            throw Abort(.unauthorized)
        }
        guard let body = try? req.content.decode(ChangePasswordDTO.self) else {
            throw Abort(.badRequest, reason: "Body does not match ChangePasswordDTO")
        }
        guard let user = try await User.query(on: req.db)
            .filter(\.$id == payload.userID!)
            .first() else {
            throw Abort(.notFound, reason: "User not found")
        }
        let isCurrentPasswordValid = try Bcrypt.verify(body.oldPassword!, created: user.passwordHash)
        guard isCurrentPasswordValid else {
            throw Abort(.unauthorized, reason: "Current password is incorrect")
        }
        do {
            user.passwordHash = try Bcrypt.hash(body.newPassword!)
            try await user.save(on: req.db)
        } catch {
            throw Abort(.internalServerError, reason: "Failed to update password: \(error.localizedDescription)")
        }
        
        return Response(status: .ok, body: .init(string: "Password changed successfully"))
    }
    
    @Sendable
    func requestPasswordReset(req: Request) async throws -> Response {
        guard let body = try? req.content.decode(RequestPasswordResetDTO.self) else {
            throw Abort(.badRequest, reason: "Body does not match RequestPasswordResetDTO")
        }
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == body.email!)
            .with(\.$identity)
            .first() else {
            return Response(status: .ok, body: .init(string: "If the email exists, a reset code has been sent."))
        }
        let resetCode = String((100000...999999).randomElement()!)
        
        let tokenEntry = PasswordResetToken(
            userID: user.id!,
            token: resetCode,
            expiresAt: Date().addingTimeInterval(3600) // 1 Stunde gültig
        )
        try await tokenEntry.create(on: req.db)
        
        // Hier muss der Code per Mail gesendet werden
        
        let emailData = SendEmailDTO(
            receiver: user.email,
            subject: "Passwort zurücksetzen",
            message: "Einmal-Code: \(tokenEntry.token)"
        )

        let response = try await req.client.post("https://kivop.ipv64.net/email") { request in
            try request.content.encode(emailData)
        }
        
        guard response.status == .ok else {
            throw Abort(.internalServerError, reason: "Failed to send email: \(response.status)")
        }
        return Response(status: .ok, body: .init(string: "If the email exists, a reset code has been sent."))
    }
    
    @Sendable
    func userResetPasswort(req: Request) async throws -> Response {
        guard let body = try? req.content.decode(ResetPasswordDTO.self) else {
            throw Abort(.badRequest, reason: "Body does not match ResetPasswordDTO")
        }
        guard let email = body.email, let resetCode = body.resetCode, let newPassword = body.newPassword else {
            throw Abort(.badRequest, reason: "Missing email, reset code, or new password")
        }
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == email)
            .first() else {
            throw Abort(.notFound, reason: "User with email \(email) not found")
        }
        guard let tokenEntry = try await PasswordResetToken.query(on: req.db)
            .filter(\.$user.$id == user.id!)
            .filter(\.$token == resetCode)
            .filter(\.$expiresAt > Date())
            .first() else {
            throw Abort(.badRequest, reason: "Invalid or expired reset code")
        }
        do {
            user.passwordHash = try Bcrypt.hash(newPassword)
            try await user.save(on: req.db)
            try await tokenEntry.delete(on: req.db)
        } catch {
            throw Abort(.internalServerError, reason: "Failed to reset password: \(error.localizedDescription)")
        }
        return Response(status: .ok, body: .init(string: "Password has been reset successfully"))
    }
}

extension Attendance: @retroactive Content { }

actor ContainerActor<T> {
    var value: T
    
    init(value: T) {
        self.value = value
    }
    
    func setValue(_ value: T) {
        self.value = value
    }
}

extension ContainerActor where T: RangeReplaceableCollection {
    func append(_ value: T.Element) {
        self.value.append(value)
    }
}


