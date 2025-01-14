import Foundation

public struct GetEventParticipationDTO: Codable {
    public var id: UUID
    public var name: String
    public var itsMe: Bool
    public var participates: UsersParticipationState
    
    public init(id: UUID, name: String, itsMe: Bool, participates: UsersParticipationState) {
        self.id = id
        self.name = name
        self.itsMe = itsMe
        self.participates = participates
    }
}

public enum UsersParticipationState: String, Codable, CaseIterable {
    case nothing
    case absent
    case present
}
