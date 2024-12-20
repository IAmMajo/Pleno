import Foundation

public struct DeleteDTO: Codable {
    public var ids: [UUID]
    
    public init(ids: [UUID]) {
        self.ids = ids
    }
}
