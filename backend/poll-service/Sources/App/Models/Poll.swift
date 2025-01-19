import Models
import PollServiceDTOs
import Vapor
import Fluent

extension Poll {
    func toGetPollDTO(db: Database, userId: User.IDValue) async throws -> GetPollDTO {
        try await .init(
            id: self.requireID(),
            question: self.question,
            description: self.description,
            startedAt: self.startedAt!,
            closedAt: self.closedAt,
            anonymous: self.anonymous,
            multiSelect: self.multiSelect,
            iVoted: !self.getMyVotes(db: db, userId: userId).isEmpty,
            isOpen: self.isOpen,
            options: self.$votingOptions.get(on: db).toGetPollVotingOptionDTOs()
        )
    }
    
    var isOpen: Bool {
        self.closedAt > .now
    }
    
    func getMyVotes(db: Database, userId: User.IDValue) async throws -> [UInt8] {
        let identityIds = try await IdentityHistory.byUserId(userId, db).map { identityHistory in
            try identityHistory.identity.requireID()
        }
        return try await self.$votingOptions.get(on: db)
            .map { option in
            if let myVote = try await option.$votes.query(on: db)
                .filter(\.$id.$identity.$id ~~ identityIds)
                .first() {
                return try myVote.requireID().$pollVotingOption.id.index
            }
            return 0
        }
            .filter { index in
                index > 0
            }
    }
    
    public func toGetPollResultsDTO(db: Database, userId: UUID) async throws -> GetPollResultsDTO {
        var getPollResultsDTO = GetPollResultsDTO()
        
        getPollResultsDTO.myVotes = try await self.getMyVotes(db: db, userId: userId)
        
        let votingOptions = try await self.$votingOptions.get(on: db).sorted { leftOption, rightOption in
            try leftOption.requireID().index < rightOption.requireID().index
        }
        
        let totalVotes: [[PollVote]] = try await votingOptions.map { option in
            try await option.$votes.get(on: db)
        }
        
        let totalVoteAmounts: [Int] = totalVotes.map { votes in
            votes.count
        }
        let totalVotesCount = totalVoteAmounts.reduce(0) { partialResult, votes in
            partialResult + votes
        }
        guard totalVotesCount > 0 else {
            return getPollResultsDTO
        }
        getPollResultsDTO.totalCount = UInt(totalVotesCount)
        
        getPollResultsDTO.identityCount = UInt(try totalVotes.flatMap { votes in
            votes
        }.uniqued { vote in
            try vote.requireID().$identity.id
        }.count)
        
        var percentageCutoffs: [PercentageCutoff] = totalVoteAmounts.enumerated().map { index, votes in
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
        
        for index in 0..<votingOptions.count {
            let percentageCutoff = percentageCutoffs[index]
            try await getPollResultsDTO.results.append(
                GetPollResultDTO(
                    index: UInt8(index + 1),
                    count: UInt(totalVoteAmounts[index]),
                    percentage: percentageCutoff.percentage,
                    identities: self.anonymous ? nil : totalVotes[index].map({ vote in
                        try await vote.requireID().$identity.get(on: db).toGetIdentityDTO()
                    })))
        }
        
        return getPollResultsDTO
    }
}

extension [Poll] {
    func toGetPollDTOs(db: Database, userId: User.IDValue) async throws -> [GetPollDTO] {
        try await self.map { poll in
            try await poll.toGetPollDTO(db: db, userId: userId)
        }
    }
}
