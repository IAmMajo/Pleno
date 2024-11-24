import Foundation

public struct PatchVotingDTO: Codable {
    public var question: String?
    public var anonymous: Bool?
    public var options: [GetVotingOptionDTO]?
    
    public init(question: String? = nil, anonymous: Bool? = nil, options: [GetVotingOptionDTO]? = nil) {
        self.question = question
        self.anonymous = anonymous
        self.options = options
    }
}
