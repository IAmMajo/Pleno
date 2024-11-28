import Foundation

public struct GetVotingDTO: Codable {
    public var id: UUID
    public var meetingId: UUID
    public var question: String
    public var description: String
    public var isOpen: Bool
    public var startedAt: Date?
    public var closedAt: Date?
    public var anonymous: Bool
    public var options: [GetVotingOptionDTO]
    
    public init(id: UUID, meetingId: UUID, question: String, description: String, isOpen: Bool, startedAt: Date? = nil, closedAt: Date? = nil, anonymous: Bool, options: [GetVotingOptionDTO]) {
        self.id = id
        self.meetingId = meetingId
        self.question = question
        self.description = description
        self.isOpen = isOpen
        self.startedAt = startedAt
        self.closedAt = closedAt
        self.anonymous = anonymous
        self.options = options
    }
}
