import Fluent
import Foundation

public final class ParticipantLocation: Model, @unchecked Sendable {
    public static let schema = "participant_locations"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "user_id")
    public var user: User
    
    @Field(key: "description")
    public var description: String?
    
    @Field(key: "latitude")
    public var latitude: Float
    
    @Field(key: "longitude")
    public var longitude: Float
    
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?
    
    public init(){}
    
    public init(id: UUID? = nil, userId: User.IDValue, description: String?, latitude: Float, longitude: Float) {
        self.id = id
        self.$user.id = userId
        self.latitude = latitude
        self.longitude = longitude
    }
}

