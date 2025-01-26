import Foundation

public enum UsersRideState: String, Codable, CaseIterable {
    case nothing
    case requested
    case accepted
    case driver
}
