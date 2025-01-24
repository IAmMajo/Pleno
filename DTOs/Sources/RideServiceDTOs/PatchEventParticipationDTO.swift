import Foundation

public struct PatchEventParticipationDTO: Codable {
    public var participates: Bool
    
    public init(participates: Bool) {
        self.participates = participates
    }
}
