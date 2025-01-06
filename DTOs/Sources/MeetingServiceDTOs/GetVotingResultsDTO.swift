import Foundation

public struct GetVotingResultsDTO: Codable {
    public var votingId: UUID
    public var myVote: UInt8? // Index 0: Abstention | nil: did not vote at all
    public var totalCount: UInt
    public var results: [GetVotingResultDTO]
    
    public init(votingId: UUID, myVote: UInt8? = nil, totalCount: UInt = 0, results: [GetVotingResultDTO] = []) {
        self.votingId = votingId
        self.myVote = myVote
        self.totalCount = totalCount
        self.results = results
    }
}
public struct GetVotingResultDTO: Codable {
    public var index: UInt8 // Index 0: Abstention
    public var count: UInt
    public var percentage: Double
    public var identities: [GetIdentityDTO]?
    
    public init(index: UInt8, count: UInt, percentage: Double, identities: [GetIdentityDTO]? = nil) {
        self.index = index
        self.count = count
        self.percentage = percentage
        self.identities = identities
    }
}
