import Foundation

public struct UserProfileUpdateDTO: Codable {
    public var name: String?
    public var profileImage: Data?
    
    public init(name: String? = nil, profileImage: Data? = nil) {
        self.name = name
        self.profileImage = profileImage
        
    }
}
