import Foundation

public struct CreatePosterDTO: Codable {
    public var name: String
    public var description: String?
    public var image: Data

    public init(name: String, description: String? = nil, image: Data) {
        self.name = name
        self.description = description
        self.image = image
    }
}

