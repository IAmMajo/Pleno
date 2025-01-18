import Foundation

public struct HangPosterPositionDTO: Codable {
    public var image: Data
    
    public init(image: Data) {
        self.image = image
    }
}
