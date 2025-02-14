package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class HangPosterPositionDTO (
    var image : String,
    var latitude : Double?,
    var longitude : Double?,
)
