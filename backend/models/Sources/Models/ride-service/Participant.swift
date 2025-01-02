import Fluent
import Foundation

public final class Participant: Model, @unchecked Sendable {
    public static let schema = "participants"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "ride_id")
    public var ride: Ride
    
    @Parent(key: "user_id")
    public var user: User
    
    @Field(key: "driver")
    public var driver: Bool
    
    @Field(key: "passengers_count")
    public var passengers_count: Int?
    
    @Field(key: "latitude")
    public var latitude: Float
    
    @Field(key: "longitude")
    public var longitude: Float
    
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?
    
    public init(){}
    
    public init(id: UUID? = nil, rideId: Ride.IDValue, userId: User.IDValue, driver: Bool, passengers_count: Int?, latitude: Float, longitude: Float) {
        self.id = id
        self.$ride.id = rideId
        self.$user.id = userId
        self.driver = driver
        self.passengers_count = passengers_count
        self.latitude = latitude
        self.longitude = longitude
    }
}

