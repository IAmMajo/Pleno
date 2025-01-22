package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class HangPosterPositionResponseDTO (
    var posterPosition : UUID,
    var postedAt : LocalDateTime,
    var postedBy : UUID,
    var image : String,
)
