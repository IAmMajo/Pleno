import Foundation

public struct GetVotingResultsDTO: Codable {
    public var votingId: UUID
    public var results: [GetVotingResultDTO]
    
    public init(votingId: UUID, results: [GetVotingResultDTO]) {
        self.votingId = votingId
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
