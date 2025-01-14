import Foundation

public struct CreateEventDTO: Codable {
    public var name: String
    public var description: String?
    public var starts: Date
    public var ends: Date
    public var latitude: Float
    public var longitude: Float
    
    public init(name: String, description: String? = nil, starts: Date, ends: Date, latitude: Float, longitude: Float) {
        self.name = name
        self.description = description
        self.starts = starts
        self.ends = ends
        self.latitude = latitude
        self.longitude = longitude
    }
}
