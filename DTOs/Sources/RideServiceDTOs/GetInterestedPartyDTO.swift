import Foundation

public struct GetInterestedPartyDTO: Codable {
    public var id: UUID
    public var eventID: UUID
    public var eventName: String
    public var latitude: Float
    public var longitude: Float
    
    public init(id: UUID, eventID: UUID, eventName: String, latitude: Float, longitude: Float) {
        self.id = id
        self.eventID = eventID
        self.eventName = eventName
        self.latitude = latitude
        self.longitude = longitude
    }
}
