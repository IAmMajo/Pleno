import PosterServiceDTOs
import Vapor

extension HangPosterPositionDTO: @retroactive Content, @unchecked @retroactive Sendable {}
