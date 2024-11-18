import Foundation

public struct PatchRecordDTO: Codable {
    public var identityId: UUID?
    public var content: String?
    
    public init(identityId: UUID? = nil, content: String? = nil) {
        self.identityId = identityId
        self.content = content
    }
}
