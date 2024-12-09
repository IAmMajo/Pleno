import Foundation

public struct PatchParticipateDTO: Codable {
    public var driver: Bool?
    public var passenger_count: Int?
    public var latitude: Float?
    public var longitude: Float?
    
    public init(driver: Bool? = nil, passenger_count: Int? = nil, latitude: Float? = nil, longitude: Float? = nil) {
        self.driver = driver
        self.passenger_count = passenger_count
        self.latitude = latitude
        self.longitude = longitude
    }
}
