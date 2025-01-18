import PosterServiceDTOs
import Vapor

extension PosterResponseDTO: @retroactive Content, @unchecked @retroactive Sendable {}
