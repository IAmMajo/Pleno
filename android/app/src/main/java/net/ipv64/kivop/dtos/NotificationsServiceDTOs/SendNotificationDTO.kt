package net.ipv64.kivop.dtos.NotificationsServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class SendNotificationDTO (
    var userID : UUID,
    var subject : String,
    var message : String,
    var payload : String?,
)
