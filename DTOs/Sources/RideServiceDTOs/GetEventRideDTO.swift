import Foundation

public struct GetEventRideDTO: Codable {
    public var id: UUID
    public var eventID: UUID
    public var eventName: String
    public var starts: Date
    public var emptySeats: UInt8
    public var allocatedSeats: UInt8
    public var myState: UsersRideState
    public var openRequests: Int?
    
    public init(id: UUID, eventID: UUID, eventName: String, starts: Date, emptySeats: UInt8, allocatedSeats: UInt8, myState: UsersRideState, openRequests: Int? = nil) {
        self.id = id
        self.eventID = eventID
        self.eventName = eventName
        self.starts = starts
        self.emptySeats = emptySeats
        self.allocatedSeats = allocatedSeats
        self.myState = myState
        self.openRequests = openRequests
    }
}
