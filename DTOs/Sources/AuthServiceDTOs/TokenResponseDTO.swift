import Fluent
import Vapor

public struct TokenResponseDTO: Content {
    public var token: String?
    
    public init(token: String? = nil) {
        self.token = token
    }
}

