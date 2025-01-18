import PosterServiceDTOs
import Vapor

extension UpdatePosterPositionDTO: @retroactive Content, @unchecked @retroactive Sendable {}
