import Fluent
import Foundation

public final class Poster: Model, @unchecked Sendable {
    public static let schema = "posters"
    
    @ID(key: .id)
    public var id: UUID?

    @Field(key: "name")
    public var name: String

    @OptionalField(key: "description")
    public var description: String?

    @Field(key: "image")
    public var image: Data
    
    @Children(for: \.$poster)
    public var positions: [PosterPosition]
   
    public init() { }

    public init(id: UUID? = nil, name: String,  description: String? = "", image: Data) {
        self.id = id
        self.name = name
        self.description = description
        self.image = image
    }
    
}


    
