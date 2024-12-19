import Foundation

public struct HangPosterPositionDTO: Codable {
    public var user: UUID
    public var poster_position: UUID
    public var image: Data
    
    public init(user: UUID, posterPosition: UUID, image: Data) {
        self.user = user
        self.poster_position = posterPosition
        self.image = image
    }
}
