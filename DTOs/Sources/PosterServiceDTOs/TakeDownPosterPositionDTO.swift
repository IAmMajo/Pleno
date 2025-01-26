import Foundation

public struct TakeDownPosterPositionDTO: Codable {
    public var image: Data

    public init( image: Data) {
        self.image = image
    }
}
