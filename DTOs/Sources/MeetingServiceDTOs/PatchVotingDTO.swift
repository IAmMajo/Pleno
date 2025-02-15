import Foundation

public struct PatchVotingDTO: Codable {
    public var question: String?
    public var description: String?
    public var anonymous: Bool?
    public var options: [GetVotingOptionDTO]? // If options is not nil: ALL previous options will be deleted/replaced
    
    public init(question: String? = nil, description: String? = nil, anonymous: Bool? = nil, options: [GetVotingOptionDTO]? = nil) {
        self.question = question
        self.description = description
        self.anonymous = anonymous
        self.options = options
    }
}


