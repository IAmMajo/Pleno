import Vapor
import AuthServiceDTOs

extension UserUpdateAccountDTO: @retroactive Content, @unchecked @retroactive Sendable, @retroactive Validatable {
    public static func validations(_ validations: inout Vapor.Validations) {
        validations.add("isActive", as: Bool.self, required: false)
        validations.add("isAdmin", as: Bool.self, required: false)
    }
}

