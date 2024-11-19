import Foundation

public struct TokenResponseDTO: Codable {
    public var token: String?
    
    public init(token: String? = nil) {
        self.token = token
    }
}

