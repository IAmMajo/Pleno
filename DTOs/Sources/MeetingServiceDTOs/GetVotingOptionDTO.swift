public struct GetVotingOptionDTO: Codable {
    public var index: UInt8
    public var text: String
    
    public init(index: UInt8, text: String) {
        self.index = index
        self.text = text
    }
}
