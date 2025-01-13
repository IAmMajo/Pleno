import Vapor
import AuthServiceDTOs

extension ChangePasswordDTO: @retroactive Content, @unchecked @retroactive Sendable {}

