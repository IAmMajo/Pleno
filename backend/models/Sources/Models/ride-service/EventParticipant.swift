import Fluent
import Foundation

public final class EventParticipant: Model, @unchecked Sendable {
    public static let schema = "event_participations"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "event_id")
    public var event: PlenoEvent
    
    @Parent(key: "user_id")
    public var user: User
    
    @Field(key: "participates")
    public var participates: Bool
    
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?
    
    public init(){}
    
    public init(id: UUID? = nil, eventID: PlenoEvent.IDValue, userID: User.IDValue, participates: Bool, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.$event.id = eventID
        self.$user.id = userID
        self.participates = participates
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
