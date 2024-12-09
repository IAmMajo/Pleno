import Vapor
import MeetingServiceDTOs

extension CreateVotingDTO: @retroactive Content, @unchecked @retroactive Sendable, @retroactive Validatable {
    public static func validations(_ validations: inout Vapor.Validations) {
        validations.add("options", as: [GetVotingOptionDTO].self, is: .validGetVotingOptionDTOArray)
    }
}
