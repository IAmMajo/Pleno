import Vapor
import MeetingServiceDTOs

extension PatchVotingDTO: @retroactive Content, @unchecked @retroactive Sendable, @retroactive Validatable {
    public static func validations(_ validations: inout Vapor.Validations) {
        validations.add("options", as: [GetVotingOptionDTO].self, is: .validGetVotingOptionDTOArray)
    }
}
