import Vapor
import AuthServiceDTOs

extension UserProfileDTO: @retroactive Content, @unchecked @retroactive Sendable {}
extension VerificationStatus: @retroactive Content, @unchecked @retroactive Sendable {}

