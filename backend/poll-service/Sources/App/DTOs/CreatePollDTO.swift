import Vapor
import PollServiceDTOs

extension CreatePollDTO: @retroactive Content, @unchecked @retroactive Sendable, @retroactive Validatable {
    public static func validations(_ validations: inout Vapor.Validations) {
        validations.add("options", as: [GetPollVotingOptionDTO].self, is: .validGetPollVotingOptionDTOArray)
    }
}
