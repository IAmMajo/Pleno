import Fluent
import Vapor

public struct UserUpdateAccountDTO: Content {
    public var isActive: Bool?
    public var isAdmin: Bool?
}

extension UserUpdateAccountDTO: Validatable {
    static public func validations(_ validations: inout Validations) {
        validations.add("isActive", as: Bool.self, required: false)
        validations.add("isAdmin", as: Bool.self, required: false)
    }
}

