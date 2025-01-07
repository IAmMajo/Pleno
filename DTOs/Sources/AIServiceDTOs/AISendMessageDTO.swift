public struct AISendMessageDTO: Codable {
    public var content: String

    public init(content: String) {
        self.content = content
    }
}
