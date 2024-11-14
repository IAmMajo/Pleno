import Foundation

public struct GetVotingDTO: Codable {
    public var id: UUID
    public var meetingId: UUID
    public var question: String
    public var isOpen: Bool
    public var startedAt: Date?
    public var closedAt: Date?
    public var anonymous: Bool
    public var options: [GetVotingOptionDTO]
}
