package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class TakeDownPosterPositionResponseDTO (
    var poster_position : UUID,
    var removed_at : LocalDateTime,
    var removed_by : UUID,
    var image_url : String,
)
