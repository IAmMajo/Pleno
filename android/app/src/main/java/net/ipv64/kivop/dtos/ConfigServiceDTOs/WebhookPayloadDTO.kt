package net.ipv64.kivop.dtos.ConfigServiceDTOs

import java.util.UUID

import java.time.LocalDateTime

data class WebhookPayloadDTO (
    var event : String,
    var settings_id : UUID,
    var new_value : SettingValueDTO?,
    var old_value : SettingValueDTO?,
)
