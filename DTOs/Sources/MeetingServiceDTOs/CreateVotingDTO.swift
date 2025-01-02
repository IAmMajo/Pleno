import Foundation

public struct CreateVotingDTO: Codable {
    public var meetingId: UUID
    public var question: String
    public var description: String?
    public var anonymous: Bool
    public var options: [GetVotingOptionDTO]
    
    public init(meetingId: UUID, question: String, description: String? = nil, anonymous: Bool, options: [GetVotingOptionDTO]) {
        self.meetingId = meetingId
        self.question = question
        self.description = description
        self.anonymous = anonymous
        self.options = options
    }
}

