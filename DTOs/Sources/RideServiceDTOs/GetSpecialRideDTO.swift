import Foundation

public struct GetSpecialRideDTO: Codable {
    public var id: UUID
    public var name: String
    public var starts: Date
    public var ends: Date
    public var emptySeats: UInt8
    public var allocatedSeats: UInt8
    public var myState: UsersRideState
    public var openRequests: Int?
    
    public init(id: UUID, name: String, starts: Date, ends: Date, emptySeats: UInt8, allocatedSeats: UInt8, myState: UsersRideState, openRequests: Int? = nil) {
        self.id = id
        self.name = name
        self.starts = starts
        self.ends = ends
        self.emptySeats = emptySeats
        self.allocatedSeats = allocatedSeats
        self.myState = myState
        self.openRequests = openRequests
    }
}
