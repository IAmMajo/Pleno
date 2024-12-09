import Foundation
import Models
import Vapor

extension Participant {
    func toParticipateDTO() -> ParticipateDTO {
        return .init(driver: self.driver, passenger_count: self.passengers_count, latitude: self.latitude, longitude: self.longitude)
    }
    
    func patchWithDTO(dto: PatchParticipateDTO) throws {
        if let latitude = dto.latitude {
            self.latitude = latitude
        }
        
        if let longitude = dto.longitude {
            self.longitude = longitude
        }
        
        if let driver = dto.driver {
            self.driver = driver
        }
        
        self.passengers_count = dto.passenger_count
        
        // check if update is valid
        if !self.isValid() {
            throw Abort(.badRequest)
        }
    }
    
    func isValid() -> Bool {
        // wenn kein driver, passenger_count sollte nil sein
        if !self.driver {
            if self.passengers_count == nil {
                return true
            }
            return false
        }
        
        // wenn driver, passenger_count muss groesser 0 sein
        guard let passengers_count = self.passengers_count else {
            return false
        }
        
        if passengers_count > 0 {
            return true
        }
        
        // sonst ungueltig
        return false
    }
}
