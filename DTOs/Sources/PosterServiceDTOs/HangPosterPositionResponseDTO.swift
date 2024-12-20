import Foundation

public struct HangPosterPositionResponseDTO: Codable {
    public var posterPosition: UUID
    public var postedAt: Date
    public var postedBy: UUID
    public var imageUrl: String
    
    public init(posterPosition: UUID, postedAt: Date, postedBy: UUID, imageUrl: String) {
        self.posterPosition = posterPosition
        self.postedAt = postedAt
        self.postedBy = postedBy
        self.imageUrl = imageUrl
    }
}
