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

public final class User: Model, Content, @unchecked Sendable {
    public static let schema = "users"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "identity_id")
    public var identity: Identity
    
    @Field(key: "email")
    public var email: String
    
    @Field(key: "password_hash")
    public var passwordHash: String
    
    @Field(key: "is_admin")
    public var isAdmin: Bool
    
    @Field(key: "is_active")
    public var isActive: Bool
    
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?
    
    @Timestamp(key: "last_login", on: .none)
    public var lastLogin: Date?
    
    @Field(key: "profile_image")
    public var profileImage: Data?
    
    @OptionalChild(for: \.$user)
    public var emailVerification: EmailVerification?
    
    @Field(key: "is_notifications_active")
    public var isNotificationsActive: Bool
    
    @Field(key: "is_push_notifications_active")
    public var isPushNotificationsActive: Bool
    
    @Children(for: \.$user)
    var notificationDevices: [NotificationDevice]
    
    public init() { }
    
    // TODO temporarily every user is active by default until email verification works. Attention for the first user!
    public init (id: UUID? = nil, identityID: Identity.IDValue, email: String, passwordHash: String, isAdmin: Bool = false, isActive: Bool = false, profileImage: Data? = nil) {
        self.id = id
        self.$identity.id = identityID
        self.email = email
        self.passwordHash = passwordHash
        self.isAdmin = isAdmin
        self.isActive = isActive
        self.profileImage = profileImage
    }
    
}
