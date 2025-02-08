import PosterServiceDTOs
import Vapor

extension ImageDTO: @retroactive Content, @unchecked @retroactive Sendable {}
