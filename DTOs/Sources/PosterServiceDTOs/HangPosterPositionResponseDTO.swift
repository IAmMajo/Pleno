import Foundation

public struct HangPosterPositionResponseDTO: Codable {
    public var posterPosition: UUID
    public var postedAt: Date
    public var postedBy: UUID
    public var latitude: Double?
    public var longitude: Double?

    public init(posterPosition: UUID, postedAt: Date, postedBy: UUID, latitude: Double? = nil, longitude: Double? = nil) {
        self.posterPosition = posterPosition
        self.postedAt = postedAt
        self.postedBy = postedBy
        self.longitude = longitude
        self.latitude = latitude
    }
}
