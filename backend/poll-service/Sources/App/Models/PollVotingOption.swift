import Models
import PollServiceDTOs

extension PollVotingOption {
    func toGetPollVotingOptionDTO() throws -> GetPollVotingOptionDTO {
        try .init(
            index: self.requireID().index,
            text: self.text
        )
    }
}

extension [PollVotingOption] {
    func toGetPollVotingOptionDTOs() throws -> [GetPollVotingOptionDTO] {
        try self.map { pollVotingOption in
            try pollVotingOption.toGetPollVotingOptionDTO()
        }
    }
}
