import Foundation

public struct WebhookPayloadDTO: Codable {
    public var event: String
    public var settings_id: UUID
    public var new_value: SettingValueDTO?
    public var old_value: SettingValueDTO?
    
    
    public init(event: String, settings_id: UUID, new_value: SettingValueDTO? = nil, old_value: SettingValueDTO? = nil) {
        self.event = event
        self.settings_id = settings_id
        self.new_value = new_value
        self.old_value = old_value
    }
}
