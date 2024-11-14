import Fluent
import Vapor

public struct UserProfileUpdateDTO: Content {
    public var name: String?
}

extension UserProfileUpdateDTO: Validatable {
    static public func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
    }
}
