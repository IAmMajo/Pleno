import Foundation

public struct UserProfileDTO: Codable {
    public var email: String?
    public var name: String?
    public var isAdmin: Bool?
    public var createdAt: Date?
    
    public init(email: String? = nil, name: String? = nil, isAdmin: Bool? = nil, createdAt: Date? = nil) {
        self.email = email
        self.name = name
        self.isAdmin = isAdmin
        self.createdAt = createdAt
    }
}
