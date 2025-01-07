import Fluent
import Vapor

public struct UserProfileDTO: Content, Sendable {
    public var uid: UUID?
    public var email: String?
    public var name: String?
    public var profileImage: Data?
    public var isAdmin: Bool?
    public var isActive: Bool?
    public var emailVerification: VerificationStatus?
    public var createdAt: Date?
}

public enum VerificationStatus: String, Codable, Sendable {
    case failed
    case verified
    case pending
}

