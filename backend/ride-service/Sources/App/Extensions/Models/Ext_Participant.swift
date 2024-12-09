import Foundation
import Models

extension Participant {
    func toParticipateDTO() -> ParticipateDTO {
        return .init(driver: self.driver, passenger_count: self.passengers_count, latitude: self.latitude, longitude: self.longitude)
    }
}
