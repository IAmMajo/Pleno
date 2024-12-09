import Fluent
import Vapor
import Models

public struct UserRegistrationDTO: Content {
    public var name: String?
    public var email: String?
    public var password: String?
    public var profileImage: Data?
}

extension UserRegistrationDTO: Validatable {
    static public func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: !.empty)
    }
}
