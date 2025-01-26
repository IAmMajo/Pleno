import Foundation 

public struct GetSpecialRideDetailDTO: Codable {
    public var id: UUID?
    public var driverName: String
    public var driverID: UUID
    public var isSelfDriver: Bool
    public var name: String
    public var description: String?
    public var vehicleDescription: String?
    public var starts: Date
    public var ends: Date
    public var startLatitude: Float
    public var startLongitude: Float
    public var destinationLatitude: Float
    public var destinationLongitude: Float
    public var emptySeats: UInt8
    public var riders: [GetRiderDTO]
    
    public init(id: UUID? = nil, driverName: String, driverID: UUID, isSelfDriver: Bool, name: String, description: String? = nil, vehicleDescription: String? = nil, starts: Date, ends: Date, startLatitude: Float, startLongitude: Float, destinationLatitude: Float, destinationLongitude: Float, emptySeats: UInt8, riders: [GetRiderDTO]) {
        self.id = id
        self.driverName = driverName
        self.driverID = driverID
        self.isSelfDriver = isSelfDriver
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
        self.riders = riders
    }
    
}
