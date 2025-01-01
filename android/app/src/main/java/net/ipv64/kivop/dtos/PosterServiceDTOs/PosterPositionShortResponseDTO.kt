package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.time.LocalDateTime
import java.util.UUID

data class PosterPositionShortResponseDTO(
    var id: UUID,
    var posterId: UUID?,
    var expiresAt: LocalDateTime,
    var status: String,
)
