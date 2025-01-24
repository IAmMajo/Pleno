import Foundation

public struct CreateEventParticipationDTO: Codable {
    public var participates: Bool
    
    public init(participates: Bool) {
        self.participates = participates
    }
}
