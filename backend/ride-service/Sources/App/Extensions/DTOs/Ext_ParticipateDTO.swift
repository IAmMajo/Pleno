import Foundation
import Vapor

extension ParticipateDTO: @retroactive Content {
    func isValid() -> Bool {
        // wenn kein driver, passenger_count sollte nil sein
        if !self.driver {
            if self.passenger_count == nil {
                return true
            }
            return false
        }
        
        // wenn driver, passenger_count muss groesser 0 sein
        guard let passenger_count = self.passenger_count else {
            return false
        }
        
        if passenger_count > 0 {
            return true
        }
        
        // sonst ungueltig
        return false
    }
}
