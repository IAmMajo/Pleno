import Foundation

public struct ParticipationDTO: Codable {
    public var driver: Bool
    public var passengers_count: Int?
    public var latitude: Float
    public var longitude: Float
    
    public init(driver: Bool, passengers_count: Int? = nil, latitude: Float, longitude: Float) {
        self.driver = driver
        self.passengers_count = passengers_count
        self.latitude = latitude
        self.longitude = longitude
    }
}
