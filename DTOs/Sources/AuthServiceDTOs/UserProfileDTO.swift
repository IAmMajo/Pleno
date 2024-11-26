import Foundation

public struct UserProfileDTO: Codable {
    public var uid: UUID?
    public var email: String?
    public var name: String?
    public var profileImage: Data?
    public var isAdmin: Bool?
    public var isActive: Bool?
    public var createdAt: Date?
    
    public init(uid: UUID, email: String? = nil, name: String? = nil, profileImage: Data? = nil, isAdmin: Bool, isActive: Bool, createdAt: Date? = nil) {
        self.uid = uid
        self.email = email
        self.name = name
        self.profileImage = profileImage
        self.isAdmin = isAdmin
        self.isActive = isActive
        self.createdAt = createdAt
    }
}
