import Foundation

public struct ChangePasswordDTO: Codable {
    public var oldPassword: String?
    public var newPassword: String?
    
    public init(oldPassword: String? = nil, newPassword: String? = nil) {
        self.oldPassword = oldPassword
        self.newPassword = newPassword
    }
}


