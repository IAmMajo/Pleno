import Fluent
import Vapor

public struct UserProfileDTO: Content {
    public var uid: UUID?
    public var email: String?
    public var name: String?
    public var isAdmin: Bool?
    public var isActive: Bool?
    public var createdAt: Date?
}
