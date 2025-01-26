import Foundation

public struct GetEventRideDTO: Codable {
    public var id: UUID
    public var eventID: UUID
    public var eventName: String
    public var driverName: String
    public var driverID: UUID
    public var starts: Date
    public var latitude: Float
    public var longitude: Float
    public var emptySeats: UInt8
    public var allocatedSeats: UInt8
    public var myState: UsersRideState
    public var openRequests: Int?
    
    public init(id: UUID, eventID: UUID, eventName: String, driverName: String, driverID: UUID, starts: Date, latitude: Float, longitude: Float, emptySeats: UInt8, allocatedSeats: UInt8, myState: UsersRideState, openRequests: Int? = nil) {
        self.id = id
        self.eventID = eventID
        self.eventName = eventName
        self.driverName = driverName
        self.driverID = driverID
        self.starts = starts
        self.latitude = latitude
        self.longitude = longitude
        self.emptySeats = emptySeats
        self.allocatedSeats = allocatedSeats
        self.myState = myState
        self.openRequests = openRequests
    }
}
