import Vapor
import AIServiceDTOs

extension AISendMessageDTO: @retroactive Content, @unchecked @retroactive Sendable { }
