import Foundation

public struct RequestPasswordResetDTO: Codable {
    public var email: String?
    
    public init(email: String? = nil) {
        self.email = email
    }
}


