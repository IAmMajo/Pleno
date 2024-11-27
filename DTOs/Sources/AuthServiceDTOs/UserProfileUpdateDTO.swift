import Foundation

public struct UserProfileUpdateDTO: Codable {
    public var name: String?
    public var isActive: Bool?
    public var isAdmin: Bool?
    
    public init(name: String? = nil, isActive: Bool? = nil, isAdmin: Bool? = nil) {
        self.name = name
        self.isActive = isActive
        self.isAdmin = isAdmin
    }
}
