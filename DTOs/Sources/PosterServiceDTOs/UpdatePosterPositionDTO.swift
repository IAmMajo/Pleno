import Foundation

public struct UpdatePosterPositionDTO: Codable {
    public var posterId: UUID?
    public var latitude: Double?
    public var longitude: Double?
    public var expiresAt: Date?
    public var responsibleUsers: [UUID]?
    public var image: Data?
    
    public init(posterId: UUID? = nil, latitude: Double? = nil, longitude: Double? = nil, imageUrl: String? = nil, expiresAt: Date? = nil, responsibleUsers: [UUID]? = nil, image: Data? = nil) {
        self.latitude = latitude 
        self.longitude = longitude 
        self.posterId = posterId
        self.expiresAt = expiresAt
        self.responsibleUsers = responsibleUsers
        self.image = image
    }
}



