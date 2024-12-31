import Foundation

public struct CreatePosterPositionDTO: Codable {
    public var posterId: UUID?
    public var latitude: Double
    public var longitude: Double
    public var responsibleUsers: [UUID]
    public var expiresAt: Date
    
    public init(posterId: UUID? = nil, latitude: Double, longitude: Double, responsibleUsers: [UUID], expiresAt: Date) {
        self.posterId = posterId
        self.latitude = latitude 
        self.longitude = longitude 
        self.responsibleUsers = responsibleUsers
        self.expiresAt = expiresAt
    }
}


