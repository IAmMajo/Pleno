import Foundation

public struct UserRegistrationDTO: Codable {
    public var name: String?
    public var email: String?
    public var password: String?
    
    public init(name: String? = nil, email: String? = nil, password: String? = nil) {
        self.name = name
        self.email = email
        self.password = password
    }
}
