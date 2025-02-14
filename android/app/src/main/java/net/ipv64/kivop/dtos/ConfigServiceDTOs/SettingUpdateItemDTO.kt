package net.ipv64.kivop.dtos.ConfigServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class SettingUpdateItemDTO (
    var id : UUID,
    var value : String,
)
