import Foundation

public struct PatchRideDTO: Codable {
    public var name: String?
    public var description: String?
    public var starts: Date?
    public var latitude: Float?
    public var longitude: Float?
    
    public init(name: String? = nil, description: String? = nil, starts: Date? = nil, latitude: Float? = nil, longitude: Float? = nil) {
        self.name = name
        self.description = description
        self.starts = starts
        self.latitude = latitude
        self.longitude = longitude
    }}
