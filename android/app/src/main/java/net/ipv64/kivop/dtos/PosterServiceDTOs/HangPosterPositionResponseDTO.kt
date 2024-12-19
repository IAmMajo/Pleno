package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class HangPosterPositionResponseDTO (
    var poster_position : UUID,
    var posted_at : LocalDateTime,
    var posted_by : UUID,
    var image_url : String,
)
