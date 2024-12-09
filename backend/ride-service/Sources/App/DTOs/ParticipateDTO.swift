import Foundation

public struct ParticipateDTO: Codable {
    public var driver: Bool
    public var passenger_count: Int?
    public var latitude: Float
    public var longitude: Float
    
    public init(driver: Bool, passenger_count: Int? = nil, latitude: Float, longitude: Float) {
        self.driver = driver
        self.passenger_count = passenger_count
        self.latitude = latitude
        self.longitude = longitude
    }
}
