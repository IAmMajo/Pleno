import Foundation

public struct UserEmailVerificationDTO: Codable {
    public var uid: UUID?
    public var name: String?
    public var isActive: Bool?
    public var emailStatus: VerificationStatus?
    public var createdAt: Date?

    // Benutzerdefinierte Dekodierung
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // UUID als String dekodieren und konvertieren
        if let uidString = try container.decodeIfPresent(String.self, forKey: .uid) {
            self.uid = UUID(uuidString: uidString)
        } else {
            self.uid = nil
        }
        
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive)
        self.emailStatus = try container.decodeIfPresent(VerificationStatus.self, forKey: .emailStatus)
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    }

    public init(uid: UUID?, name: String?, isActive: Bool?, emailStatus: VerificationStatus?, createdAt: Date?) {
        self.uid = uid
        self.name = name
        self.isActive = isActive
        self.emailStatus = emailStatus
        self.createdAt = createdAt
    }

    private enum CodingKeys: String, CodingKey {
        case uid
        case name
        case isActive
        case emailStatus
        case createdAt
    }
}

public enum VerificationStatus: String, Codable {
    case failed
    case pending
    case verified
}
