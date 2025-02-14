package net.ipv64.kivop.dtos.NotificationsServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class RegisterNotificationDeviceDTO (
    var deviceID : String,
    var token : String,
    var platform : NotificationPlatform,
)
enum class NotificationPlatform {
    android,
    ios,
}
