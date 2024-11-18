import Foundation

public struct UserProfileUpdateDTO: Codable {
    public var name: String?
    
    public init(name: String? = nil) {
        self.name = name
    }
}
