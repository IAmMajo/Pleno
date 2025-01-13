import AIServiceDTOs
import Vapor

extension AISendMessageDTO: @retroactive Content, @unchecked @retroactive Sendable { }
