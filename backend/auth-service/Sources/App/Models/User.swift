import Fluent
import Vapor

final class User: Model, Content, @unchecked Sendable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "email")
    var email: String

    @Field(key: "name")
    var name: String

    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "role")
    var role: String
    
    @Boolean(key: "is_active")
    var isActive: Bool
    
    init() { }

    init(id: UUID? = nil, name: String, email: String, passwordHash: String, role: String) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
        self.role = role
        self.isActive = false
    }
    
    func toDTO() -> UserDTO {
        .init(
            id: self.id,
            email: self.$email.value,
            name: self.$name.value,
            passwordHash: self.$passwordHash.value,
            role: self.$role.value,
            isActive: self.$isActive.value
        )
    }
}

extension User: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("name", as: String.self, is: !.empty)
        validations.add("passwordHash", as: String.self, is: !.empty)
    }
}

