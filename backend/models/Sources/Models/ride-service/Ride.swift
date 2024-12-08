import Fluent
import Foundation

public final class Ride: Model, @unchecked Sendable {
    public static let schema = "rides"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "name")
    public var name: String
    
    @Field(key: "description")
    public var description: String?
    
    @Field(key: "starts")
    public var starts: Date
    
    @Field(key: "latitude")
    public var latitude: Float
    
    @Field(key: "longitude")
    public var longitude: Float
    
    @Parent(key: "organizer_id")
    public var organizer: User
    
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?
    
    public init(){}
    
    public init(id: UUID? = nil, name: String, description: String?, starts: Date, latitude: Float, longitude: Float, organizerId: User.IDValue) {
        self.id = id
        self.name = name
        self.description = description
        self.starts = starts
        self.latitude = latitude
        self.longitude = longitude
        self.$organizer.id = organizerId
    }
}

