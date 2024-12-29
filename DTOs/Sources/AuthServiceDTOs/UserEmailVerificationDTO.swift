import Foundation

public struct UserEmailVerificationDTO: Codable {
    public var uid: UUID?
    public var name: String?
    public var isActive: Bool?
    public var emailStatus: VerificationStatus?
    public var createdAt: Date?
    
    public init(uid: UUID, name: String? = nil, isActive: Bool? = nil, emailStatus: VerificationStatus, createdAt: Date? = nil) {
        self.uid = uid
        self.name = name
        self.isActive = isActive
        self.emailStatus = emailStatus
        self.createdAt = createdAt
    }
}

public enum VerificationStatus: Codable {
    case failed
    case pending
    case verified
}
