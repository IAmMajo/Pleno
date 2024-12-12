import Fluent
import Vapor

public struct UserProfileUpdateDTO: Content {
    public var name: String?
    public var profileImage: Data?
}

extension UserProfileUpdateDTO: Validatable {
    static public func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty, required: false)
        validations.add("profileImage", as: Data.self, required: false)
    }
}
