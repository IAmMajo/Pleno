import Vapor
import Fluent

public struct ResetPasswordDTO: Content {
    public var email: String?
    public var resetCode: String?
    public var newPassword: String?
}
