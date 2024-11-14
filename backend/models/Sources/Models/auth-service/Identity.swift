import Fluent
import Vapor

public final class Identity: Model, Content, @unchecked Sendable {
    public static let schema = "identities"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "name")
    public var name: String
    
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?
    
    public init() {}
    
    public init (id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
    
    public func clone() -> Identity {
        let newIdentity = Identity(name: self.name)
        return newIdentity
    }
}
