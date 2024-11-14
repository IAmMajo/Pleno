import Foundation

public struct GetVotingResultsDTO: Codable {
    public var votingId: UUID
    public var results: [GetVotingResultDTO]
}
public struct GetVotingResultDTO: Codable {
    public var index: UInt8 // Index 0: Abstention
    public var total: UInt8
    public var percentage: Double
    public var identities: [GetIdentityDTO]?
}
