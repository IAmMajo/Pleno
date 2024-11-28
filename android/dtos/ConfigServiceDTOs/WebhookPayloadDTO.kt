public data class WebhookPayloadDTO {
    public var event : String
    public var settings_id : Uuid
    public var new_value : SettingValueDTO?
    public var old_value : SettingValueDTO?
}
