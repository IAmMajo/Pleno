import Foundation

public struct CreateInterestedPartyDTO: Codable {
    public var eventID: UUID
    public var latitude: Float
    public var longitude: Float
    
    public init(eventID: UUID, latitude: Float, longitude: Float) {
        self.eventID = eventID
        self.latitude = latitude
        self.longitude = longitude
    }
}
