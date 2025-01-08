import Fluent
import Foundation

public final class SpecialRideRequest: Model, @unchecked Sendable {
    public static let schema = "special_ride_requests"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "user_id")
    public var user: User
    
    @Parent(key: "special_ride_id")
    public var ride: SpecialRide
    
    @Field(key: "accepted")
    public var accepted: Bool
    
    @Field(key: "latitude")
    public var latitude: Float
    
    @Field(key: "longitude")
    public var longitude: Float
    
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?
    
    public init(){}
    
    public init(id: UUID? = nil, userID: User.IDValue, rideID: SpecialRide.IDValue, accepted: Bool, latitude: Float, longitude: Float, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.$user.id = userID
        self.$ride.id = rideID
        self.accepted = accepted
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
   
}
