import Models
import MeetingServiceDTOs

extension VotingOption {
    public func toGetVotingOptionDTO() throws -> GetVotingOptionDTO {
        try .init(votingId: self.requireID().voting.requireID(),
                  index: self.requireID().index,
                  text: self.text)
    }
}
