import Foundation

public struct PatchInterestedPartyDTO: Codable {
    public var latitude: Float?
    public var longitude: Float?
    
    public init(latitude: Float?, longitude: Float?) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
