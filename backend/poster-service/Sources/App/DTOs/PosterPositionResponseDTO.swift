import PosterServiceDTOs
import Vapor


extension PosterPositionResponseDTO: @retroactive Content, @unchecked @retroactive Sendable {
}
