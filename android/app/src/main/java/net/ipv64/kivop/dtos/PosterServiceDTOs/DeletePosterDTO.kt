package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class DeleteDTO (
    public let ids: List<UUID>
)
