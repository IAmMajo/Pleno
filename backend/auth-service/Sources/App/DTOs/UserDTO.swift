import Fluent
import Vapor
import Models

public struct UserDTO: Content {
    public var id: UUID?
    public var email: String?
    public var name: String?
    public var passwordHash: String?
    public var role: String?
    public var isActive: Bool?
    
    public func toModel() -> User {
        let model = User()
        
        model.id = self.id
        if let email = self.email {
            model.email = email
        }
        
        if let name = self.name {
            model.name = name
        }
        
        if let passwordHash = self.passwordHash {
            model.passwordHash = passwordHash
        }
        
        if let role = self.role {
            model.role = role
        }
        
        if let isActive = self.isActive {
            model.isActive = isActive
        }
        
        return model
    }
}

