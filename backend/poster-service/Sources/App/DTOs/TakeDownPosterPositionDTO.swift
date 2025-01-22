import PosterServiceDTOs
import Vapor

extension TakeDownPosterPositionDTO: @retroactive Content, @unchecked @retroactive Sendable {}
