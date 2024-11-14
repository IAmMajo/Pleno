import Foundation

public struct GetVotingOptionDTO: Codable {
    public var votingId: UUID
    public var index: UInt8
    public var text: String
    
    public init(votingId: UUID, index: UInt8, text: String) {
        self.votingId = votingId
        self.index = index
        self.text = text
    }
}
