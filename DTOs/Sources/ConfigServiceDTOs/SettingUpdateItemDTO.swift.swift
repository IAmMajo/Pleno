import Foundation

public struct SettingUpdateItemDTO: Codable {
    public var id: UUID
    public var value: String
    
    public init(id: UUID, value: String) {
        self.id = id
        self.value = value
    }
}
