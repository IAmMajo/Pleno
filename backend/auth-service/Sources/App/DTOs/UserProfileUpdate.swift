import Fluent
import Vapor

public struct UserProfileUpdateDTO: Content {
    public var name: String?
    public var isActive: Bool?
    public var isAdmin: Bool?
}

extension UserProfileUpdateDTO: Validatable {
    static public func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty, required: false)
        validations.add("isActive", as: Bool.self, required: false)
        validations.add("isAdmin", as: Bool.self, required: false)
    }
}
