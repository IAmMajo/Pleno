import Foundation

public struct GetIdentityDTO: Codable {
    public var id: UUID
    public var name: String
    
    public init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
}
