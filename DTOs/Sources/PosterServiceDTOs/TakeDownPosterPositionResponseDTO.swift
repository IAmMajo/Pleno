import Foundation

public struct TakeDownPosterPositionResponseDTO: Codable {
    public var posterPosition: UUID
    public var removedAt: Date
    public var removedBy: UUID
    public var image: Data
    
    public init(posterPosition: UUID, removedAt: Date, removedBy: UUID, image: Data) {
        self.posterPosition = posterPosition
        self.removedAt = removedAt
        self.removedBy = removedBy
        self.image = image
    }
}
