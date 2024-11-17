import Fluent
import Vapor

public struct UserProfileUpdateDTO: Content {
    public var name: String?
    
    public init(name: String? = nil) {
        self.name = name
    }
}
