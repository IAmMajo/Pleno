import Foundation

public struct PatchParticipationDTO: Codable {
    public var driver: Bool?
    public var passengers_count: Int?
    public var latitude: Float?
    public var longitude: Float?
    
    public init(driver: Bool? = nil, passengers_count: Int? = nil, latitude: Float? = nil, longitude: Float? = nil) {
        self.driver = driver
        self.passengers_count = passengers_count
        self.latitude = latitude
        self.longitude = longitude
    }
}
