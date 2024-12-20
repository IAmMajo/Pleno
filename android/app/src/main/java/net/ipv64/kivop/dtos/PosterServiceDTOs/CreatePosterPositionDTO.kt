package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.time.LocalDateTime
import java.util.UUID

data class CreatePosterPositionDTO (
    var posterId : UUID?,
    var latitude : Double,
    var longitude : Double,
    var responsibleUsers : List<UUID>,
    var expiresAt : LocalDateTime,
)
