import Foundation

public struct ResetPasswordDTO: Codable {
    public var email: String?
    public var resetCode: String?
    public var newPassword: String?
    
    public init(email: String? = nil, resetCode: String? = nil, newPassword: String? = nil) {
        self.email = email
        self.resetCode = resetCode
        self.newPassword = newPassword
    }
}


