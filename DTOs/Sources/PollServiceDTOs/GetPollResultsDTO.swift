import Foundation

public struct GetPollResultsDTO: Codable {
    public var myVotes: [UInt8] // empty: did not vote at all
    public var totalCount: UInt
    public var identityCount: UInt
    public var results: [GetPollResultDTO]
    
    public init(myVotes: [UInt8] = [], totalCount: UInt = 0, identityCount: UInt = 0, results: [GetPollResultDTO] = []) {
        self.myVotes = myVotes
        self.totalCount = totalCount
        self.identityCount = identityCount
        self.results = results
    }
}
public struct GetPollResultDTO: Codable {
    public var index: UInt8
    public var text: String
    public var count: UInt
    public var percentage: Double
    public var identities: [GetIdentityDTO]?
    
    public init(index: UInt8, text: String, count: UInt, percentage: Double, identities: [GetIdentityDTO]? = nil) {
        self.index = index
        self.text = text
        self.count = count
        self.percentage = percentage
        self.identities = identities
    }
}
