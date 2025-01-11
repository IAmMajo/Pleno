import Foundation

public struct GetRiderDTO: Codable {
    public var id: UUID
    public var username: String
    public var latitude: Float
    public var longitude: Float
    public var istMe: Bool
    public var accepted: Bool
    
    public init(id: UUID, username: String, latitude: Float, longitude: Float, istMe: Bool, accepted: Bool) {
        self.id = id
        self.username = username
        self.latitude = latitude
        self.longitude = longitude
        self.istMe = istMe
        self.accepted = accepted
    }
}
