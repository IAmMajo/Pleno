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
