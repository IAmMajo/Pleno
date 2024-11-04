import Fluent
import Vapor

public final class User: Model, Content, @unchecked Sendable {
    public static let schema = "users"

    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "email")
    public var email: String

    @Field(key: "name")
    public var name: String

    @Field(key: "password_hash")
    public var passwordHash: String
    
    @Field(key: "role")
    public var role: String
    
    @Boolean(key: "is_active")
    public var isActive: Bool
    
    public init() { }

    public init(id: UUID? = nil, name: String, email: String, passwordHash: String, role: String) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
        self.role = role
        self.isActive = false
    }
}

extension User: Validatable {
    public static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("name", as: String.self, is: !.empty)
        validations.add("passwordHash", as: String.self, is: !.empty)
    }
}

