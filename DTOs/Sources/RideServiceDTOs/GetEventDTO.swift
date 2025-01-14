import Foundation

public struct GetEventDTO: Codable {
    public var id: UUID
    public var name: String
    public var starts: Date
    public var ends: Date
    public var myState: UsersEventState
    
    public init(id: UUID, name: String, starts: Date, ends: Date, myState: UsersEventState) {
        self.id = id
        self.name = name
        self.starts = starts
        self.ends = ends
        self.myState = myState
    }
}

public enum UsersEventState: String, Codable, CaseIterable {
    case nothing
    case absent
    case present
}
