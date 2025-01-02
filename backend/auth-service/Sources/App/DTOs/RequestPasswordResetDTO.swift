import Vapor
import Fluent

public struct RequestPasswordResetDTO: Content {
    public var email: String?
}

