import Foundation
import Vapor
import RideServiceDTOs

extension ParticipationDTO: @retroactive Content {
    func isValid() -> Bool {
        // wenn kein driver, passengers_count sollte nil sein
        if !self.driver {
            if self.passengers_count == nil {
                return true
            }
            return false
        }
        
        // wenn driver, passengers_count muss groesser 0 sein
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
