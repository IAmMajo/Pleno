import Foundation

public struct CreatePosterPositionDTO: Codable {
    public var latitude: Double
    public var longitude: Double
    public var responsibleUsers: [UUID]
    public var expiresAt: Date
    
    public init( latitude: Double, longitude: Double, responsibleUsers: [UUID], expiresAt: Date) {
        self.latitude = latitude 
        self.longitude = longitude 
        self.responsibleUsers = responsibleUsers
        self.expiresAt = expiresAt
    }
}


