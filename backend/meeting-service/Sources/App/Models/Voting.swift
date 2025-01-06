import Models
import MeetingServiceDTOs
import Vapor
import Fluent

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
    
    public func toGetVotingResultsDTO(db: Database, userId: UUID? = nil) async throws -> GetVotingResultsDTO {
        guard !self.isOpen && self.startedAt != nil && self.closedAt != nil else {
            throw Abort(.conflict, reason: "The voting has not closed yet.")
        }
        
        var getVotingResultsDTO = try GetVotingResultsDTO(votingId: self.requireID(), myVote: nil, results: [])
        
        if let userId {
            let identityIds = try await IdentityHistory.byUserId(userId, db).map { identityHistory in
                try identityHistory.identity.requireID()
            }
            if let myVote = try await self.$votes.query(on: db)
                .with(\.$id.$identity)
                .filter(\.$id.$identity.$id ~~ identityIds)
                .first() {
                getVotingResultsDTO.myVote = myVote.index
            }
        }
        
        let votingOptions = try await self.$votingOptions.get(on: db)
        
        var totalVotes: [[Vote]] = []
        
        for i in 0...votingOptions.count {
            try await totalVotes.append(self.$votes.query(on: db)
                .filter(\.$index == UInt8(i))
                .with(\.$id.$identity)
                .all())
        }
        let totalVoteAmounts: [Int] = totalVotes.map { votes in
            votes.count
        }
        let totalVotesCount = totalVoteAmounts.reduce(0) { partialResult, votes in
            partialResult + votes
        }
        guard totalVotesCount > 0 else {
            return getVotingResultsDTO
        }
        getVotingResultsDTO.totalCount = UInt(totalVotesCount)
        
        var percentageCutoffs: [percentageCutoff] = totalVoteAmounts.enumerated().map { index, votes in
            let percentage = (Double(votes) / Double(totalVotesCount))
            let roundedDownPercentage = (percentage * 10000.0).rounded(.down) / 100.0
            return .init(index: UInt8(index), percentage: roundedDownPercentage, cutoff: percentage - roundedDownPercentage)
        }
        
        percentageCutoffs.sort { percentageCutoff1, percentageCutoff2 in
            percentageCutoff1.cutoff > percentageCutoff2.cutoff
        }
        let totalPercentage = percentageCutoffs.reduce(0.0) { partialResult, percentageCutoff in
            partialResult + percentageCutoff.percentage
        }
        
        for i in 0..<(Int((100.0 - totalPercentage)*100.0)) {
            percentageCutoffs[i].percentage += 0.01
        }
        percentageCutoffs.sort { percentageCutoff1, percentageCutoff2 in
            percentageCutoff1.index < percentageCutoff2.index
        }
        
        for index in 0...votingOptions.count {
            let percentageCutoff = percentageCutoffs[index]
            try getVotingResultsDTO.results.append(
                GetVotingResultDTO(index: UInt8(index),
                                   count: UInt(totalVoteAmounts[index]),
                                   percentage: percentageCutoff.percentage,
                                   identities: self.anonymous ? nil : totalVotes[index].map({ vote in
                                       try vote.requireID().identity.toGetIdentityDTO()
                                   })))
        }
        
        return getVotingResultsDTO
    }
}
