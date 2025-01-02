import Fluent
import Vapor

public final class PasswordResetToken: Model, Content, @unchecked Sendable {
    public static let schema = "password_reset_tokens"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "user_id")
    public var user: User
    
    @Field(key: "token")
    public var token: String
    
    @Field(key: "expires_at")
    public var expiresAt: Date
    
    public init() {}
    
    public init(id: UUID? = nil, userID: User.IDValue, token: String, expiresAt: Date) {
        self.id = id
        self.$user.id = userID
        self.token = token
        self.expiresAt = expiresAt
    }
}

