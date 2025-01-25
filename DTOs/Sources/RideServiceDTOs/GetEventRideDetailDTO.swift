import Foundation

public struct GetEventRideDetailDTO: Codable {
    public var id: UUID
    public var eventID: UUID
    public var eventName: String
    public var driverName: String
    public var driverID: UUID
    public var isSelfDriver: Bool
    public var description: String?
    public var vehicleDescription: String?
    public var starts: Date
    public var latitude: Float
    public var longitude: Float
    public var emptySeats: UInt8
    public var riders: [GetRiderDTO]
    
    public init(id: UUID, eventID: UUID, eventName: String, driverName: String, driverID: UUID, isSelfDriver: Bool, description: String? = nil, vehicleDescription: String? = nil, starts: Date, latitude: Float, longitude: Float, emptySeats: UInt8, riders: [GetRiderDTO]) {
        self.id = id
        self.eventID = eventID
        self.eventName = eventName
        self.driverName = driverName
        self.driverID = driverID
        self.isSelfDriver = isSelfDriver
        self.description = description
        self.vehicleDescription = vehicleDescription
        self.starts = starts
        self.latitude = latitude
        self.longitude = longitude
        self.emptySeats = emptySeats
        self.riders = riders
    }
    
}
