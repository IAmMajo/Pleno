import Foundation

public struct GetRiderDTO: Codable {
    public var id: UUID
    public var username: String
    public var latitude: Float
    public var longitude: Float
    public var itsMe: Bool
    public var accepted: Bool
    
    public init(id: UUID, username: String, latitude: Float, longitude: Float, itsMe: Bool, accepted: Bool) {
        self.id = id
        self.username = username
        self.latitude = latitude
        self.longitude = longitude
        self.itsMe = itsMe
        self.accepted = accepted
    }
}
