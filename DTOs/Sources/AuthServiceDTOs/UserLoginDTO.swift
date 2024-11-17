import Fluent
import Vapor

public struct UserLoginDTO: Content {
    public var email: String?
    public var password: String?
    
    public init(email: String? = nil, password: String? = nil) {
        self.email = email
        self.password = password
    }
}
