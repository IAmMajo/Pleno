import Fluent
import Vapor
import Models

public struct UserLoginDTO: Content {
    public var email: String?
    public var password: String?
}

extension UserLoginDTO: Validatable {
    static public func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: !.empty)
    }
}
