import Foundation

public struct UserProfileUpdateDTO: Codable {
    public var name: String?
    public var profileImage: Data?
    public var isNotificationsActive: Bool?
    public var isPushNotificationsActive: Bool?
    
    public init(name: String? = nil, profileImage: Data? = nil, isNotificationsActive: Bool? = nil, isPushNotificationsActive: Bool? = nil) {
        self.name = name
        self.profileImage = profileImage
        self.isNotificationsActive = isNotificationsActive
        self.isPushNotificationsActive = isPushNotificationsActive
    }
}
