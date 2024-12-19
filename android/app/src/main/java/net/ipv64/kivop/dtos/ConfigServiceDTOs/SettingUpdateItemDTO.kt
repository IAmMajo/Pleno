package net.ipv64.kivop.dtos.ConfigServiceDTOs

import java.util.UUID

data class SettingUpdateItemDTO(
    var id: UUID,
    var value: String,
)
