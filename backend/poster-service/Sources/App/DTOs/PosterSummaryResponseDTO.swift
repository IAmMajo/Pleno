import PosterServiceDTOs
import Vapor

extension PosterSummaryResponseDTO: @retroactive Content, @unchecked @retroactive Sendable {}
