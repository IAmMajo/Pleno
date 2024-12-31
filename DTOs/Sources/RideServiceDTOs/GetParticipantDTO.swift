import Foundation

public struct GetParticipantDTO: Codable {
    public var id: UUID?
    public var name: String
    public var driver: Bool
    public var passengers_count: Int?
    public var latitude: Float
    public var longitude: Float
    public var itsMe: Bool
    
    public init(id: UUID?, name: String, driver: Bool, passengers_count: Int?, latitude: Float, longitude: Float, itsMe: Bool) {
        self.id = id
        self.name = name
        self.driver = driver
        self.passengers_count = passengers_count
        self.latitude = latitude
        self.longitude = longitude
        self.itsMe = itsMe
    }
}
