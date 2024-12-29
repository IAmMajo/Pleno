public struct SettingBulkUpdateDTO: Codable {
    public var updates: [SettingUpdateItemDTO]
    
    public init(updates: [SettingUpdateItemDTO]) {
        self.updates = updates
    }
}
