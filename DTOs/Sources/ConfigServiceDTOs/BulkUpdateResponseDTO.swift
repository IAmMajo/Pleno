import Foundation

public struct BulkUpdateResponseDTO: Codable {
    public var updated: [UUID]
    public var failed: [UUID: String]
    
    public init(updated: [UUID], failed: [UUID: String]) {
        self.updated = updated
        self.failed = failed
    }
}
