package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class PosterPositionShortResponseDTO (
    var id : UUID,
    var posterId : UUID?,
    var expires_at : LocalDateTime,
    var status : String,
)
