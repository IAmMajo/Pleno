import Foundation

public struct PosterResponseDTO: Codable {
    public var id: UUID
    public var name: String
    public var description: String?
    public var image: Data
   
    public init(id: UUID, name: String, description: String? = nil, image: Data) {
        self.id = id
        self.name = name
        self.description = description
        self.image = image
       
    }
}

