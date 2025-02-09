import Fluent
import Foundation

public final class PosterPosition: Model,@unchecked Sendable {
    public static let schema = "poster_positions"

    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "poster_id")
    public var poster: Poster
    
    @Field(key: "latitude")
    public var latitude: Double

    @Field(key: "longitude")
    public var longitude: Double

    @Field(key: "posted_at")
    public var postedAt: Date?
    
    @OptionalParent(key: "posted_by")
    public var postedBy: Identity?
    
    @Field(key: "expires_at")
    public var expiresAt: Date
    
    @Field(key: "removed_at")
    public var removedAt: Date?
    
    @OptionalParent(key: "removed_by")
    public var removedBy: Identity?
    
    @Field(key:"image")
    public var image: Data?
    
    @Field(key:"damaged")
    public var damaged: Bool
    
    @Children(for: \.$poster_position)
    public var responsibilities: [PosterPositionResponsibilities]
    
    public init() { }

public init(
    id: UUID? = nil,
    posterId: UUID,
    latitude: Double,
    longitude: Double,
    expiresAt: Date
) {
    self.id = id
    self.latitude = round(latitude * 1_000_000) / 1_000_000
    self.longitude = round(longitude * 1_000_000) / 1_000_000
    self.$poster.id = posterId
    self.expiresAt = expiresAt
    self.image = nil
    self.postedAt = nil
    self.$postedBy.id = nil
    self.removedAt = nil
    self.$removedBy.id = nil
    self.damaged = false
}

}
