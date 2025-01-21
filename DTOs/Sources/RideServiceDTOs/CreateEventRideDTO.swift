import Foundation

public struct CreateEventRideDTO: Codable {
    public var eventID: UUID
    public var description: String?
    public var vehicleDescription: String?
    public var starts: Date
    public var latitude: Float
    public var longitude: Float
    public var emptySeats: UInt8
    
    public init(eventID: UUID, description: String? = nil, vehicleDescription: String? = nil, starts: Date, latitude: Float, longitude: Float, emptySeats: UInt8) {
        self.eventID = eventID
        self.description = description
        self.vehicleDescription = vehicleDescription
        self.starts = starts
        self.latitude = latitude
        self.longitude = longitude
        self.emptySeats = emptySeats
    }
}
