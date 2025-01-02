import Fluent
import Models
import Fluent
import Vapor

public struct UserEmailVerificationDTO: Content, Sendable {
    public var uid: UUID?
    public var name: String?
    public var isActive: Bool?
    public var emailStatus: VerificationStatus?
    public var createdAt: Date?
}

public enum  VerificationStatus: String, Codable, Sendable {
    case failed
    case pending
    case verified
}

