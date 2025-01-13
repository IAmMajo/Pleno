import Vapor
import AuthServiceDTOs

extension RequestPasswordResetDTO: @retroactive Content, @unchecked @retroactive Sendable {}

