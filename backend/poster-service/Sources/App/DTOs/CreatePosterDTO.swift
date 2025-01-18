import PosterServiceDTOs
import Vapor

extension CreatePosterDTO: @retroactive Content, @unchecked @retroactive Sendable {}
