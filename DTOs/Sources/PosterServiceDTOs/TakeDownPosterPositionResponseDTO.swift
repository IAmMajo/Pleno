import Foundation

public struct TakeDownPosterPositionResponseDTO: Codable {
    public var posterPosition: UUID
    public var removedAt: Date
    public var removedBy: UUID
    public var imageUrl: String
    
    public init(posterPosition: UUID, removedAt: Date, removedBy: UUID, imageUrl: String) {
        self.posterPosition = posterPosition
        self.removedAt = removedAt
        self.removedBy = removedBy
        self.imageUrl = imageUrl
    }
}
