import Foundation

public struct TakeDownPosterPositionDTO: Codable {
    public var poster_position: UUID
    public var image: Data

    public init(posterPosition: UUID, image: Data) {
        self.poster_position = posterPosition
        self.image = image
    }
}
