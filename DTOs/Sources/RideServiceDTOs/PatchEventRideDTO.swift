import Foundation

public struct PatchEventRideDTO: Codable {
    public var description: String?
    public var vehicleDescription: String?
    public var starts: Date?
    public var latitude: Float?
    public var longitude: Float?
    public var emptySeats: UInt8?
    
    public init(description: String? = nil, vehicleDescription: String? = nil, starts: Date? = nil, latitude: Float? = nil, longitude: Float? = nil, emptySeats: UInt8? = nil) {
        self.description = description
        self.vehicleDescription = vehicleDescription
        self.starts = starts
        self.latitude = latitude
        self.longitude = longitude
        self.emptySeats = emptySeats
    }
}
