import PosterServiceDTOs
import Vapor

extension TakeDownPosterPositionResponseDTO: @retroactive Content, @unchecked @retroactive Sendable {}
