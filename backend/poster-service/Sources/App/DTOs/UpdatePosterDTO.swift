import PosterServiceDTOs
import Vapor

extension UpdatePosterDTO: @retroactive Content, @unchecked @retroactive Sendable {}
