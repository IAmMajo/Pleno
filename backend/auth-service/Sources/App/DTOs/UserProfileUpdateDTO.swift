import Vapor
import AuthServiceDTOs

extension UserProfileUpdateDTO: @retroactive Content, @unchecked @retroactive Sendable, @retroactive Validatable {
    public static func validations(_ validations: inout Vapor.Validations) {
        validations.add("name", as: String.self, is: !.empty, required: false)
        validations.add("profileImage", as: Data.self, required: false)
    }
}
