import Foundation

public struct GetVotingResultsDTO: Codable {
    public var votingId: UUID
    public var myVote: UInt8? // Index 0: Abstention | nil: did not vote at all
    public var results: [GetVotingResultDTO]
    
    public init(votingId: UUID, myVote: UInt8? = nil, results: [GetVotingResultDTO]) {
        self.votingId = votingId
        self.myVote = myVote
        self.results = results
    }
}
public struct GetVotingResultDTO: Codable {
    public var index: UInt8 // Index 0: Abstention
    public var total: UInt8
    public var percentage: Double
    public var identities: [GetIdentityDTO]?
    
    public init(index: UInt8, total: UInt8, percentage: Double, identities: [GetIdentityDTO]? = nil) {
        self.index = index
        self.total = total
        self.percentage = percentage
        self.identities = identities
    }
}
