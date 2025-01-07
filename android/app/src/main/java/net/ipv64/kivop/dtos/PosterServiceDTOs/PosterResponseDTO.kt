package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class PosterResponseDTO (
    var id : UUID,
    var name : String,
    var description : String?,
    var imageUrl : String,
)
