// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
        
        for (i, option) in votingOptions.enumerated() {
            let index = try option.requireID().index
            let percentageCutoff = percentageCutoffs[i]
            try await getPollResultsDTO.results.append(
                GetPollResultDTO(
                    index: index,
                    text: option.text,
                    count: UInt(totalVoteAmounts[i]),
                    percentage: percentageCutoff.percentage,
                    identities: self.anonymous ? nil : totalVotes[i].map({ vote in
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
