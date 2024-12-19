package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class TakeDownPosterPositionDTO (
    var user : UUID,
    var poster_position : UUID,
    var image :Data
)
