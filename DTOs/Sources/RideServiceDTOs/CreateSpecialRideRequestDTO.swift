import Foundation

public struct CreateSpecialRideRequestDTO: Codable {
    public var latitude: Float
    public var longitude: Float
    
    public init(latitude: Float, longitude: Float) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
