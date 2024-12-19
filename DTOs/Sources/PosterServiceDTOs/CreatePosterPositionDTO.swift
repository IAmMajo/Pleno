import Foundation

public struct CreatePosterPositionDTO: Codable {
    public var posterId: UUID?
    public var latitude: Double
    public var longitude: Double
    public var responsible_users: [UUID]
    public var expires_at: Date
    
    public init(posterId: UUID? = nil, latitude: Double, longitude: Double, responsibleUsers: [UUID], expiresAt: Date) {
        self.posterId = posterId
        self.latitude = latitude 
        self.longitude = longitude 
        self.responsible_users = responsibleUsers
        self.expires_at = expiresAt
    }
}


