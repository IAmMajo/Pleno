package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class HangPosterPositionDTO (
    var poster_position : UUID,
    var image : ByteArray,
)
