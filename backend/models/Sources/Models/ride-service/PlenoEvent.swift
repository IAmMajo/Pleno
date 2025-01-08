import Fluent
import Foundation

public final class PlenoEvent: Model, @unchecked Sendable {
    public static let schema = "pleno_events"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "name")
    public var name: String
    
    @Field(key: "description")
    public var description: String?
    
    @Field(key: "starts")
    public var starts: Date
    
    @Field(key: "ends")
    public var ends: Date
    
    @Field(key: "latitude")
    public var latitude: Float
    
    @Field(key: "longitude")
    public var longitude: Float
    
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?
    
    public init(){}
    
    public init(id: UUID? = nil, name: String, description: String? = nil, starts: Date, ends: Date, latitude: Float, longitude: Float, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.starts = starts
        self.ends = ends
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
