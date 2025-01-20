import Foundation

public struct PatchEventRideRequestDTO: Codable {
    public var accepted: Bool
    
    public init(accepted: Bool) {
        self.accepted = accepted
    }
}
