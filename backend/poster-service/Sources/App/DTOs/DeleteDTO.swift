import PosterServiceDTOs
import Vapor

extension DeleteDTO: @retroactive Content, @unchecked @retroactive Sendable {}

