import Fluent
import Vapor

public final class IdentityHistory: Model, Content, @unchecked Sendable {
    public static let schema = "identity_history"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "user_id")
    public var user: User
    
    @Parent(key: "identity_id")
    public var identity: Identity
    
    @Timestamp(key: "valid_from", on: .create)
    public var validFrom: Date?
    
    public init() {}
    
    public init(id: UUID? = nil, userID: User.IDValue, identityID: Identity.IDValue) {
        self.id = id
        self.$user.id = userID
        self.$identity.id = identityID
    }
}

