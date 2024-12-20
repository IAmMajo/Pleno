package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.time.LocalDateTime
import java.util.UUID

data class TakeDownPosterPositionResponseDTO(
    var posterPosition: UUID,
    var removedAt: LocalDateTime,
    var removedBy: UUID,
    var imageUrl: String,
)
