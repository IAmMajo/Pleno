import Foundation

public struct CreatePollDTO: Codable {
    public var question: String
    public var description: String?
    public var closedAt: Date
    public var anonymous: Bool
    public var multiSelect: Bool
    public var options: [GetPollVotingOptionDTO]
    
    public init(question: String, description: String? = nil, closedAt: Date, anonymous: Bool, multiSelect: Bool, options: [GetPollVotingOptionDTO]) {
        self.question = question
        self.description = description
        self.closedAt = closedAt
        self.anonymous = anonymous
        self.multiSelect = multiSelect
        self.options = options
    }
}
