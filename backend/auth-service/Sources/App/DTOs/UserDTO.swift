import Fluent
import Vapor

struct UserDTO: Content {
    var id: UUID?
    var email: String?
    var name: String?
    var passwordHash: String?
    var role: String?
    var isActive: Bool?
    
    func toModel() -> User {
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

