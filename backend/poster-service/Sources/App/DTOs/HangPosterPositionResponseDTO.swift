import PosterServiceDTOs
import Vapor

extension HangPosterPositionResponseDTO: @retroactive Content, @unchecked @retroactive Sendable {}
