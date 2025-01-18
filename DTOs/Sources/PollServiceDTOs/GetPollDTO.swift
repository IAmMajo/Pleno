import Foundation

public struct GetPollDTO: Codable {
    public var id: UUID
    public var question: String
    public var description: String
    public var startedAt: Date
    public var closedAt: Date
    public var anonymous: Bool
    public var multiSelect: Bool
    public var iVoted: Bool
    public var isOpen: Bool
    public var options: [GetPollVotingOptionDTO]
    
    public init(id: UUID, question: String, description: String, startedAt: Date, closedAt: Date, anonymous: Bool, multiSelect: Bool, iVoted: Bool, isOpen: Bool, options: [GetPollVotingOptionDTO]) {
        self.id = id
        self.question = question
        self.description = description
        self.startedAt = startedAt
        self.closedAt = closedAt
        self.anonymous = anonymous
        self.multiSelect = multiSelect
        self.iVoted = iVoted
        self.isOpen = isOpen
        self.options = options
    }
}
