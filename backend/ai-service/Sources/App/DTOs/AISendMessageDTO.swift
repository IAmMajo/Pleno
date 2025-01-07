import Vapor

// TODO: Replace with DTO from DTOs package
public struct AISendMessageDTO: Content {
    public var content: String

    public init(content: String) {
        self.content = content
    }
}

//extension AISendMessageDTO: @retroactive Content { }
