import Foundation

public struct UserUpdateAccountDTO: Codable {
    public var isActive: Bool?
    public var isAdmin: Bool?
    
    public init(isActive:Bool? = true, isAdmin: Bool? = false) {
        self.isActive = isActive
        self.isAdmin = isAdmin
        
    }
}

