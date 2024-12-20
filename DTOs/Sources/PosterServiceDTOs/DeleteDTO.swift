import Foundation

public struct DeleteDTO: Codable {
    public let ids: [UUID]
    
    public init(ids: [UUID]) {
        self.ids = ids
    }
}
