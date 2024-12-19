package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class PosterPositionResponseDTO (
    var id : UUID,
    var posterId : UUID?,
    var latitude : Double,
    var longitude : Double,
    var postedBy : UUID?,
    var postedAt : LocalDateTime?,
    var expiresAt : LocalDateTime,
    var removedBy : UUID?,
    var removedAt : LocalDateTime?,
    var imageUrl : String?,
    var responsibleUsers : List<UUID>,
    var status : String,
)
