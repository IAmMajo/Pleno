public struct UpdatePosterDTO: Codable {
    public var name: String?
    public var description: String?
    public var image: Data?
    
    public init(name: String? = nil, description: String? = nil, image: Data? = nil) {
        self.name = name
        self.description = description
        self.image = image
    }
}
