import Foundation

public struct PatchSpecialRideDTO: Codable {
    public var name: String?
    public var description: String?
    public var vehicleDescription: String?
    public var starts: Date?
    public var ends: Date?
    public var startLatitude: Float?
    public var startLongitude: Float?
    public var destinationLatitude: Float?
    public var destinationLongitude: Float?
    public var emptySeats: UInt8?
    
    public init(name: String? = nil, description: String? = nil, vehicleDescription: String? = nil, starts: Date? = nil, ends: Date? = nil, startLatitude: Float? = nil, startLongitude: Float? = nil, destinationLatitude: Float? = nil, destinationLongitude: Float? = nil, emptySeats: UInt8? = nil) {
        self.name = name
        self.description = description
        self.vehicleDescription = vehicleDescription
        self.starts = starts
        self.ends = ends
        self.startLatitude = startLatitude
        self.startLongitude = startLongitude
        self.destinationLatitude = destinationLatitude
        self.destinationLongitude = destinationLongitude
        self.emptySeats = emptySeats
    }
}
