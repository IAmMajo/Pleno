import Foundation

public struct PatchSpecialRideRequestDTO: Codable {
    public var latitude: Float?
    public var longitude: Float?
    public var accepted: Bool?
    
    public init(latitude: Float? = nil, longitude: Float? = nil, accepted: Bool? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.accepted = accepted
    }
}
