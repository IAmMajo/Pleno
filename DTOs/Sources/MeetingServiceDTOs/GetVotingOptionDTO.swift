import Foundation

public struct GetVotingOptionDTO: Codable {
    public var votingId: UUID
    public var index: UInt8
    public var text: String
}
