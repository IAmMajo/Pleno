import Fluent
import Foundation

public final class EventRide: Model, @unchecked Sendable {
    public static let schema = "event_rides"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "event_id")
    public var event: PlenoEvent
    
    @Parent(key: "participant_id")
    public var participant: EventParticipant
    
    @Field(key: "starts")
    public var starts: Date
    
    @Field(key: "latitude")
    public var latitude: Float
    
    @Field(key: "longitude")
    public var longitude: Float
    
    @Field(key: "emptySeats")
    public var emptySeats: Int
    
    @Field(key: "description")
    public var description: String?
    
    @Field(key: "vehicle_description")
    public var vehicleDescription: String?
    
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?
    
    public init(){}
    
    public init(id: UUID? = nil, eventID: PlenoEvent.IDValue, participantID: EventParticipant.IDValue, starts: Date, latitude: Float, longitude: Float, emptySeats: Int, description: String? = nil, vehicleDescription: String? = nil, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.$event.id = eventID
        self.$participant.id = participantID
        self.starts = starts
        self.latitude = latitude
        self.longitude = longitude
        self.emptySeats = emptySeats
        self.description = description
        self.vehicleDescription = vehicleDescription
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
