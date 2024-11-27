import Models
import MeetingServiceDTOs

extension VotingOption {
    public func toGetVotingOptionDTO() throws -> GetVotingOptionDTO {
        try .init(index: self.requireID().index,
                  text: self.text)
    }
}
