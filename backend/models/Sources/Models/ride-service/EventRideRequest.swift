import Fluent
import Foundation

public final class EventRideRequest: Model, @unchecked Sendable {
    public static let schema = "event_ride_requests"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "event_ride_id")
    public var ride: EventRide
    
    @Parent(key: "interested_party_id")
    public var interestedParty: EventRideInteresedParty
    
    @Field(key: "accepted")
    public var accepted: Bool
    
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?
    
    public init(){}
    
    public init(id: UUID? = nil, rideID: EventRide.IDValue, interestedPartyID: EventRideInteresedParty.IDValue, accepted: Bool, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.$ride.id = rideID
        self.$interestedParty.id = interestedPartyID
        self.accepted = accepted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
   
}
