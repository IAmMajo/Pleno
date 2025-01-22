import Foundation

public struct HangPosterPositionDTO: Codable {
    public var image: Data
    public var latitude: Double?
    public var longitude: Double?
    
    public init(image: Data, latitude: Double? = nil, longitude: Double? = nil) {
        self.image = image
        self.latitude = latitude
        self.longitude = longitude
    }
}
