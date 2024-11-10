import Fluent
import Vapor
import Models

public struct TokenResponseDTO: Content {
    public var token: String?
}

