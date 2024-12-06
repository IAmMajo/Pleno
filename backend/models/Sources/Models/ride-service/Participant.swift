import Fluent
import Foundation

public final class Participant: Model, @unchecked Sendable {
    public static let schema = "participants"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "ride_id")
    public var ride: Ride
    
    @Parent(key: "location_id")
    public var location: ParticipantLocation
    
    @Parent(key: "user_id")
    public var user: User
    
    @Field(key: "driver")
    public var driver: Bool
    
    @Field(key: "passengers_count")
    public var passengers_count: Int?
    
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?
    
    public init(){}
    
    public init(id: UUID? = nil, rideId: Ride.IDValue, locationId: ParticipantLocation.IDValue, userId: User.IDValue, driver: Bool, passengers_count: Int?) {
        self.id = id
        self.$ride.id = rideId
        self.$location.id = locationId
        self.$user.id = userId
        self.driver = driver
        self.passengers_count = passengers_count
    }
}

