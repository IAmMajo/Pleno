import Foundation

public struct ImageDTO: Codable {
    public var image: Data

    public init(image: Data) {
        self.image = image
    }
}

