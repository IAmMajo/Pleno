package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.time.LocalDateTime
import java.util.UUID

data class HangPosterPositionResponseDTO(
    var posterPosition: UUID,
    var postedAt: LocalDateTime,
    var postedBy: UUID,
    var imageUrl: String,
)
