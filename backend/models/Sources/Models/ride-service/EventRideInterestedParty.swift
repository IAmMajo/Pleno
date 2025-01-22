import Fluent
import Foundation

public final class EventRideInterestedParty: Model, @unchecked Sendable {
    public static let schema = "event_ride_interested_parties"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "participant_id")
    public var participant: EventParticipant
    
    @Field(key: "latitude")
    public var latitude: Float
    
    @Field(key: "longitude")
    public var longitude: Float
    
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?
    
    public init(){}
    
    public init(id: UUID? = nil, participantID: EventParticipant.IDValue, latitude: Float, longitude: Float, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.$participant.id = participantID
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
