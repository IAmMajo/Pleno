package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class CreatePosterDTO (
    var name : String,
    var description : String?,
    var image : ByteArray,
)
