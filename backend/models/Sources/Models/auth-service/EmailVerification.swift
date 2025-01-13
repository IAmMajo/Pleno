import Fluent
import Vapor

public final class EmailVerification: Model, Content, @unchecked Sendable {
    public static let schema = "email_verifications"
    
    @ID(custom: "email", generatedBy: .user)
    public var id: String?
    
    @Parent(key: "user_id")
    public var user: User
    
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

    public init(email: String, user: User.IDValue, code: String, status: VerificationStatus, expiresAt: Date) {
        self.id = email
        self.$user.id = user
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


