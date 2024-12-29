import Fluent
import Vapor

public final class EmailVerification: Model, Content, @unchecked Sendable {
    public static let schema = "email_verifications"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "user_id")
    public var user: User
    
    @Field(key: "email")
    public var email: String
    
    @Field(key: "code")
    public var code: String
    
    @Enum(key: "status")
    public var status: VerificationStatus
    
    @Timestamp(key: "expires_at", on: .none)
    public var expiresAt: Date?
    
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?
    
    @Timestamp(key: "verified_at", on: .none)
    public var verifiedAt: Date?
    
    public init() { }

    public init(id: UUID? = nil, user: User.IDValue, email: String, code: String, status: VerificationStatus, expiresAt: Date) {
        self.id = id
        self.$user.id = user
        self.email = email
        self.code = code
        self.status = status
        self.expiresAt = expiresAt
    }
}

public enum VerificationStatus: String, Codable, @unchecked Sendable {
    case failed
    case pending
    case verified
}


