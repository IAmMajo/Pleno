import Foundation

public struct GetRideOverviewDTO: Codable {
    public var id: UUID?
    public var name: String
    public var description: String?
    public var starts: Date
    public var latitude: Float
    public var longitude: Float
    
    public init(id: UUID? = nil, name: String, description: String? = nil, starts: Date, latitude: Float, longitude: Float) {
        self.id = id
        self.name = name
        self.description = description
        self.starts = starts
        self.latitude = latitude
        self.longitude = longitude
    }
}
