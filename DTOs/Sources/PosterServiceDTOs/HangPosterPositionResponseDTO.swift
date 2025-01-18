import Foundation

public struct HangPosterPositionResponseDTO: Codable {
    public var posterPosition: UUID
    public var postedAt: Date
    public var postedBy: UUID
    public var image: Data

    public init(posterPosition: UUID, postedAt: Date, postedBy: UUID, image: Data) {
        self.posterPosition = posterPosition
        self.postedAt = postedAt
        self.postedBy = postedBy
        self.image = image
    }
}
