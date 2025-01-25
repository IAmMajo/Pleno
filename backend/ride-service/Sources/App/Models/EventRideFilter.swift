import Foundation
import Vapor

struct EventRideFilter: Content {
    var byUserEvents: Bool?
    var byEventID: UUID?
}
