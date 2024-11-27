import Models
import MeetingServiceDTOs

extension Voting {
    public func toGetVotingDTO() throws -> GetVotingDTO {
        try .init(id: self.requireID(),
                  meetingId: self.$meeting.id,
                  question: self.question,
                  description: self.description,
                  isOpen: self.isOpen,
                  startedAt: self.startedAt,
                  closedAt: self.closedAt,
                  anonymous: self.anonymous,
                  options: self.votingOptions.map({ votingOption in
            try votingOption.toGetVotingOptionDTO()
        }))
    }
}
