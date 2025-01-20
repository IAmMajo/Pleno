package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class TakeDownPosterPositionResponseDTO (
    var posterPosition : UUID,
    var removedAt : LocalDateTime,
    var removedBy : UUID,
    var image : String,
)
