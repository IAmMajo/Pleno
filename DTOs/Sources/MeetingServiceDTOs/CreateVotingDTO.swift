import Foundation

public struct CreateVotingDTO: Codable {
    public var meetingId: UUID
    public var question: String
    public var anonymous: Bool
    public var options: [GetVotingOptionDTO]
    
    public init(meetingId: UUID, question: String, anonymous: Bool, options: [GetVotingOptionDTO]) {
        self.meetingId = meetingId
        self.question = question
        self.anonymous = anonymous
        self.options = options
    }
}
