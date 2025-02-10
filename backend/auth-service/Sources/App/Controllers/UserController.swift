import Fluent
import Vapor
import Models
import JWT
import NotificationsServiceDTOs
import AuthServiceDTOs
@preconcurrency import VaporToOpenAPI

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
            body: .type(RequestPasswordResetDTO.self),
            statusCode: .ok
        )
        userRoutes.put("password", "reset", use: self.userResetPasswort).openAPI(
            summary: "Reset Password with code",
            description: "Reset Password with email, code and new password",
            body: .type(ResetPasswordDTO.self),
            statusCode: .ok
        )
        
        let authMiddleware = AuthMiddleware(payloadType: JWTPayloadDTO.self)
        let protectedRoutes = userRoutes.grouped(authMiddleware)
        
        userRoutes.on(.POST, "register", body: .collect(maxSize: "7000kb"), use: self.register).openAPI(
            summary: "Register an account",
            description: "Register an account to new Members",
            body: .type(UserRegistrationDTO.self),
            contentType: .application(.json),
            response: .type(UserRegistrationDTO.self),
            statusCode: .created
        )
        userRoutes.put("email", "resend", ":email", use: self.resendVerificationEmail).openAPI(
            summary: "Resend verification email",
            description: "Resend pending verification link",
            contentType: .application(.json),
            statusCode : .ok
        )
        
        protectedRoutes.get("profile", use: self.getProfile).openAPI(
            summary: "Get profile",
            description: "Get current profile of user",
            body: .none,
            response: .type(UserProfileDTO.self),
            responseContentType: .application(.json),
            statusCode: .ok,
            auth: AuthMiddleware.schemeObject
        )
        protectedRoutes.on(.PATCH, "profile", body: .collect(maxSize: "7000kb"), use: self.userUpdateUserProfile).openAPI(
            summary: "Update profile",
            description: "Update identity and/or profileImage",
            body: .type(UserProfileUpdateDTO.self),
            response: .type(HTTPResponseStatus.self),
            statusCode: .ok,
            auth: AuthMiddleware.schemeObject
        )
        
        protectedRoutes.on(.PATCH, "profile", ":id", body: .collect(maxSize: "7000kb"), use: self.adminUpdateUserProfile).openAPI(
            summary: "Admin Update user profile",
            description: "Admin Update identity and/or profileImage",
            body: .type(UserProfileUpdateDTO.self),
            response: .type(HTTPResponseStatus.self),
            statusCode: .ok,
            auth: AuthMiddleware.schemeObject
        )
        
        // GET /users -> alle User
        protectedRoutes.get(use: self.getAllUsers).openAPI(
            summary: "Admin get all users",
            description: "List all user profiles",
            body: .none,
            response: .type(UserProfileDTO.self),
            responseContentType: .application(.json),
            statusCode: .ok,
            auth: AuthMiddleware.schemeObject
            
        )
        // GET /users/:id -> ein User
        protectedRoutes.get(":id", use: self.getUser).openAPI(
            summary: "Admin get a user profile",
            description: "Get User with user id",
            body: .none,
            response: .type(UserProfileDTO.self),
            responseContentType: .application(.json),
            statusCode: .ok,
            auth: AuthMiddleware.schemeObject
            
            
        )
        // GET /users/identities/:id
        protectedRoutes.get("identities", ":id", use: self.getIdentities).openAPI(
            summary: "Admin get all user identites",
            description: "Get all identites with user id",
            response: .type(Identity.self),
            responseContentType: .application(.json),
            statusCode: .ok,
            auth: AuthMiddleware.schemeObject
            
        )
        // PATCH /users/:id
        protectedRoutes.patch(":id", use: self.updateUserStatus).openAPI(
            summary: "Patch isActive or isAdmin",
            description: "Admin Patch user profile status",
            body: .type(UserUpdateAccountDTO.self),
            contentType: .application(.json),
            response: .type(HTTPResponseStatus.self),
            statusCode: .ok,
            auth: AuthMiddleware.schemeObject
            
        )
        // DELETE /users/:id
        protectedRoutes.delete(":id", use: self.deleteUser).openAPI(
            summary: "Admin delete user account",
            description: "Admin can delete user account with user id",
            response: .type(HTTPResponseStatus.self),
            statusCode: .noContent,
            auth: AuthMiddleware.schemeObject
            
        )
        // GET /users/profile-image/identity/:identity_id
        protectedRoutes.get("profile-image", "identity", ":id", use: self.getImageIdentity).openAPI(
            summary: "Get profile image",
            description: "Get profile image with identity id",
            responseContentType: .application(.json),
            statusCode: .ok,
            auth: AuthMiddleware.schemeObject
            
        )
        // GET /users/profile-image/user/:user_id
        protectedRoutes.get("profile-image", "user", ":id", use: self.getImageUser).openAPI(
            summary: "Get profile image",
            description: "Get profile image with user id",
            responseContentType: .application(.json),
            statusCode: .ok,
            auth: AuthMiddleware.schemeObject
            
            
        )
        // GET /users/identities
        protectedRoutes.get("identities", use: self.userGetIdentities).openAPI(
            summary: "Get identities",
            description: "Get own identities with JWT-Token",
            response: .type(Identity.self),
            responseContentType: .application(.json),
            statusCode: .ok,
            auth: AuthMiddleware.schemeObject
            
        )
        // DELETE /users/delete
        protectedRoutes.delete("delete", use: self.userDeleteEntry).openAPI(
            summary: "Delete user account",
            description: "Delete own user account with JWT-Token",
            response: .type(HTTPResponseStatus.self),
            responseContentType: .application(.json),
            statusCode: .noContent,
            auth: AuthMiddleware.schemeObject
            
        )
        // PATCH /users/change-password
        protectedRoutes.patch("change-password", use: self.userChangePassword).openAPI(
            summary: "Change password",
            description: "Change password with old password",
            body: .type(ChangePasswordDTO.self),
            contentType: .application(.json),
            statusCode: .ok,
            auth: AuthMiddleware.schemeObject
        )
    }
    
    @Sendable
    func adminUpdateUserProfile(req: Request) async throws -> HTTPStatus {
        guard let payload = req.jwtPayload else {
            throw Abort(.unauthorized)
        }
        guard payload.isAdmin == true else {
            throw Abort(.forbidden, reason: "User is not an admin")
        }
        guard let userID = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing user id")
        }
        return try await updateProfile(req: req, userID: userID)
    }
    
    @Sendable
    func userUpdateUserProfile(req: Request) async throws -> HTTPStatus {
        guard let payload = req.jwtPayload else {
            throw Abort(.unauthorized)
        }
        guard let userID = payload.userID else {
            throw Abort(.internalServerError)
        }
        return try await updateProfile(req: req, userID: userID)
    }
    
    
    func updateProfile(req: Request, userID: UUID) async throws -> HTTPStatus {
        // decode updates
        let update = try req.content.decode(UserProfileUpdateDTO.self)
        
        /// **Verbesserungsvorschlag**:
        guard let user = try await User.find(userID, on: req.db) else {
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
            
            if let newIsNotificationsActive = update.isNotificationsActive {
                user.isNotificationsActive = newIsNotificationsActive
            }
            
            if let newIsPushNotificationsActive = update.isPushNotificationsActive {
                guard user.isNotificationsActive == true else {
                    throw Abort(.forbidden, reason: "Notifications are disabled.")
                }
                user.isPushNotificationsActive = newIsPushNotificationsActive
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
        guard let payload = req.jwtPayload else {
            throw Abort(.unauthorized)
        }
        
        guard let userID = payload.userID else {
            throw Abort(.internalServerError, reason: "Cannot unwrap userID")
        }
        // query user
        guard let user = try await User.query(on: req.db)
            .filter(\.$id == userID)
            .with(\.$identity)
            .with(\.$emailVerification)
            .first() else {
            throw Abort(.notFound)
        }
        
        guard let userIDNumber = try? user.requireID(), let userCreatedAt = user.createdAt, let emailVerification = user.emailVerification, let userEmailVerificationStatus = AuthServiceDTOs.VerificationStatus(rawValue: emailVerification.status.rawValue) else {
            throw Abort(.internalServerError, reason: "Error unwrapping userID or createdAt")
        }
        
        // build reponse object
        let response = UserProfileDTO(
            uid: userIDNumber,
            email: user.email,
            name: user.identity.name,
            profileImage: user.profileImage,
            isAdmin: user.isAdmin,
            isActive: user.isActive,
            emailVerification: userEmailVerificationStatus,
            createdAt: userCreatedAt,
            isNotificationsActive: user.isNotificationsActive,
            isPushNotificationsActive: user.isPushNotificationsActive
        )
        return response
    }
    
    @Sendable
    func register(req: Request) async throws -> Response {
        // validate content
        try UserRegistrationDTO.validate(content: req)
        
        // parse registration data
        guard let registrationData = try? req.content.decode(UserRegistrationDTO.self), let registrationEmail = registrationData.email, let registrationPassword = registrationData.password, let registrationName = registrationData.name else {
            throw Abort(.internalServerError, reason: "Cant decode user registration data")
        }
        
        // check for user with same email
        let count = try await User.query(on: req.db).filter(\.$email == registrationEmail).count()
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
        let identity = Identity(name: registrationName)
        
        // save identity in database
        try await identity.create(on: req.db)
        
        // hash password
        let passwordHash = try req.password.hash(registrationPassword)
        
        // extract identity id
        let identityID = try identity.requireID()
        
        // create new user
        let user = User(identityID: identityID, email: registrationEmail, passwordHash: passwordHash, profileImage: profileImageData)
        
        // the first user becomes admin and instant access
        let countAll = try await User.query(on: req.db).count()
        if countAll == 0 {
            user.isAdmin = true
            user.isActive = true
        }
        
        user.isNotificationsActive = true
        user.isPushNotificationsActive = false
        
        // save user in database
        try await user.create(on: req.db)
        
        // extract identity id
        let userID = try user.requireID()
        
        // create history object
        let history = IdentityHistory(userID: userID, identityID: identityID)
        
        // save history entry
        try await history.create(on: req.db)
        
        let verificationCode = String(format: "%06d", Int.random(in: 0...999999))
            
        let emailVerification = EmailVerification(
            email: user.email,
            user: userID,
            code: verificationCode,
            status: .pending,
            expiresAt: Date().addingTimeInterval(3600)
        )
        
        try await emailVerification.create(on: req.db)
        
        guard let userEmailVerificationStatus = AuthServiceDTOs.VerificationStatus(rawValue: emailVerification.status.rawValue) else {
            throw Abort(.internalServerError, reason: "Cannot unwrap email verification status")
        }
        
        let registeredUser = UserProfileDTO(
            uid: userID,
            email: user.email,
            name: identity.name,
            profileImage: user.profileImage,
            isAdmin: user.isAdmin,
            isActive: user.isActive,
            emailVerification: userEmailVerificationStatus,
            createdAt: user.createdAt!,
            isNotificationsActive: user.isNotificationsActive,
            isPushNotificationsActive: user.isPushNotificationsActive
        )
        
        let emailString = try emailVerification.requireID()
        
        let url = req.application.baseURL
        
        let verifyLink = "\(url)/auth/email/verify/\(emailString)/\(verificationCode)"
        
        let emailData = SendEmailDTO(
            receiver: user.email,
            subject: "Email-Verifizierung",
            message: "Verifizierungslink: \(verifyLink)"
        )
        
        let response = try await req.client.post("http://notifications-service/internal/email") { request in
            try request.content.encode(emailData)
        }
        
        guard response.status == .ok else {
            throw Abort(.internalServerError, reason: "Failed to send email: \(response.status)")
        }
        
        return try await registeredUser.encodeResponse(status: .created, for: req)
    }
    
    @Sendable
    func resendVerificationEmail(req: Request) async throws -> Response {
        // Übergibt Email aus Parameter
        guard let email = req.parameters.get("email", as: String.self) else {
            throw Abort(.badRequest, reason: "Invalid or missing email")
        }
        
        // Sucht den Eintrag anhand der Email
        guard let emailVerification = try await EmailVerification.find(email, on: req.db) else {
            return Response(status: .ok, body: .init(string: "If the email exists, a new verification email has been sent."))
        }
        guard let emailExpiresAt = emailVerification.expiresAt else {
            throw Abort(.internalServerError, reason: "Cannot unwrap expiresAt")
        }
        
        // Prüft ob der Eintrag noch nicht als verifiziert wurde
        guard emailVerification.status != .verified else {
            return Response(status: .alreadyReported, body: .init(string: "Email already verified"))
        }
        
        // Prüft ob der Eintrag schon abgelaufen ist
        if emailExpiresAt < Date() {
            let newVerificationCode = String(format: "%06d", Int.random(in: 0...999999))
                    
            if emailVerification.status == .failed {
                emailVerification.status = .pending
            }
            emailVerification.code = newVerificationCode
            emailVerification.expiresAt = Date().addingTimeInterval(3600)
            
            try await emailVerification.update(on: req.db)
            
            let emailString = try emailVerification.requireID()
            
            let url = req.application.baseURL
            
            let verifyLink = "\(url)/auth/email/verify/\(emailString)/\(emailVerification.code)"
            
            let emailData = SendEmailDTO(
                receiver: emailString,
                subject: "Email-Verifizierung",
                message: "Verifizierungslink: \(verifyLink)"
            )
            
            _ = try await req.client.post("http://notifications-service/internal/email", content: emailData)
    
            return Response(status: .ok, body: .init(string: "If the email exists, a new verification email has been sent."))
        } else {
            if emailVerification.status == .failed {
                emailVerification.status = .pending
                let newVerificationCode = String(format: "%06d", Int.random(in: 0...999999))
                emailVerification.code = newVerificationCode
                try await emailVerification.update(on: req.db)
            }
            
            let emailString = try emailVerification.requireID()
            
            let url = req.application.baseURL
            
            let verifyLink = "\(url)/auth/email/verify/\(emailString)/\(emailVerification.code)"
            
            let emailData = SendEmailDTO(
                receiver: emailString,
                subject: "Email-Verifizierung",
                message: "Verifizierungslink: \(verifyLink)"
            )
            
            _ = try await req.client.post("http://notifications-service/internal/email", content: emailData)
            
            return Response(status: .ok, body: .init(string: "If the email exists, a new verification email has been sent."))
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
            guard let userIDNumber = try? user.requireID(), let userCreatedAt = user.createdAt, let emailVerification = user.emailVerification, let userEmailVerificationStatus = AuthServiceDTOs.VerificationStatus(rawValue: emailVerification.status.rawValue) else {
                throw Abort(.internalServerError, reason: "Error unwrapping userID, createdAt or emailverification")
            }
            let profileDTO = UserProfileDTO(
                uid: userIDNumber,
                email: user.email,
                name: user.identity.name,
                profileImage: user.profileImage,
                isAdmin: user.isAdmin,
                isActive: user.isActive,
                emailVerification: userEmailVerificationStatus,
                createdAt: userCreatedAt,
                isNotificationsActive: user.isNotificationsActive,
                isPushNotificationsActive: user.isPushNotificationsActive
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
        
        guard let userIDNumber = try? user.requireID(), let userCreatedAt = user.createdAt, let emailVerification = user.emailVerification, let userEmailVerificationStatus = AuthServiceDTOs.VerificationStatus(rawValue: emailVerification.status.rawValue) else {
            throw Abort(.internalServerError, reason: "Error unwrapping userID, createdAt or emailverification")
        }
        
        // Gibt ProfilDTO zurück
        return UserProfileDTO(
            uid: userIDNumber,
            email: user.email,
            name: user.identity.name,
            profileImage: user.profileImage,
            isAdmin: user.isAdmin,
            isActive: user.isActive,
            emailVerification: userEmailVerificationStatus,
            createdAt: userCreatedAt,
            isNotificationsActive: user.isNotificationsActive,
            isPushNotificationsActive: user.isPushNotificationsActive
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
                id: history.identity.id,
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
        
        guard let user = try await User.find(userID, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        if let isActive = update.isActive {
            user.isActive = isActive
        }
        if let isAdmin = update.isAdmin {
            user.isAdmin = isAdmin
        }
        
        try await user.update(on: req.db)
        
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
        guard let user = try await User.find(userID, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        let identityHistories = try await IdentityHistory.query(on: req.db)
            .filter(\.$user.$id == userID)
            .all()
        
        for identityHistory in identityHistories {
            identityHistory.$user.id = nil
            try await identityHistory.update(on: req.db)
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
                id: history.identity.id,
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
        guard let userID = payload.userID else {
            throw Abort(.internalServerError, reason: "Cannot unwrap userID")
        }
        guard let user = try await User.find(userID, on: req.db) else {
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
        guard let userID = payload.userID, let userOldPassword = body.oldPassword, let userNewPassword = body.newPassword else {
            throw Abort(.internalServerError, reason: "Cannot unwrap userID, oldPassword or newPassword")
        }
        guard let user = try await User.find(userID, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        let isCurrentPasswordValid = try Bcrypt.verify(userOldPassword, created: user.passwordHash)
        guard isCurrentPasswordValid else {
            throw Abort(.unauthorized, reason: "Current password is incorrect")
        }
        do {
            user.passwordHash = try Bcrypt.hash(userNewPassword)
            try await user.update(on: req.db)
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
        guard let bodyEmail = body.email else {
            throw Abort(.internalServerError, reason: "Cannot unwrap email")
        }
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == bodyEmail)
            .with(\.$identity)
            .first() else {
            return Response(status: .ok, body: .init(string: "If the email exists, a reset code has been sent."))
        }
        let resetCode = String((100000...999999).randomElement()!)
        
        let userID = try user.requireID()
        
        let tokenEntry = PasswordResetToken(
            userID: userID,
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
        
        let response = try await req.client.post("http://notifications-service/internal/email") { request in
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
        let userID = try user.requireID()
        
        guard let tokenEntry = try await PasswordResetToken.query(on: req.db)
            .filter(\.$user.$id == userID)
            .filter(\.$token == resetCode)
            .filter(\.$expiresAt > Date())
            .first() else {
            throw Abort(.badRequest, reason: "Invalid or expired reset code")
        }
        do {
            user.passwordHash = try Bcrypt.hash(newPassword)
            try await user.update(on: req.db)
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


