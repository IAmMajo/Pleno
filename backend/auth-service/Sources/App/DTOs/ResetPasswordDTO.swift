import Vapor
import AuthServiceDTOs

extension ResetPasswordDTO: @retroactive Content, @unchecked @retroactive Sendable {}
