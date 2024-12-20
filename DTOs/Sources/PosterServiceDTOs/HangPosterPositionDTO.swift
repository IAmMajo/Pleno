import Foundation

public struct HangPosterPositionDTO: Codable {
    public var posterPosition: UUID
    public var image: Data
    
    public init(posterPosition: UUID, image: Data) {
        self.posterPosition = posterPosition
        self.image = image
    }
}
