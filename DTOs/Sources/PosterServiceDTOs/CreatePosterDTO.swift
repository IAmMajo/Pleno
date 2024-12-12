public struct CreatePosterDTO: Codable {
    public var name: String
    public var description: String?
    public var imageBase64: String // Bild als Base64-String

    public init(name: String, description: String?, imageBase64: String) {
        self.name = name
        self.description = description
        self.imageBase64 = imageBase64
    }
}
