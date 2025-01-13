import Vapor
import AuthServiceDTOs

extension TokenResponseDTO: @retroactive Content, @unchecked @retroactive Sendable {}

