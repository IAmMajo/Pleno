import Fluent
import Vapor

public struct ChangePasswordDTO: Content {
    public var oldPassword: String?
    public var newPassword: String?
}

