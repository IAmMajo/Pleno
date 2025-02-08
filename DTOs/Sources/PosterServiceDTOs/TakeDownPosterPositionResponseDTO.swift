import Foundation

public struct TakeDownPosterPositionResponseDTO: Codable {
    public var posterPosition: UUID
    public var removedAt: Date
    public var removedBy: UUID
    
    public init(posterPosition: UUID, removedAt: Date, removedBy: UUID) {
        self.posterPosition = posterPosition
        self.removedAt = removedAt
        self.removedBy = removedBy
    }
}
