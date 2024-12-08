package net.ipv64.kivop.dtos

data class WebhookPayloadDTO (
    var event : String,
    var settings_id : Uuid,
    var new_value : SettingValueDTO?,
    var old_value : SettingValueDTO?,
)
