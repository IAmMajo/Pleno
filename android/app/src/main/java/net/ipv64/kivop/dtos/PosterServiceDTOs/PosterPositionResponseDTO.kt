package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class PosterPositionResponseDTO (
    var id : UUID,
    var posterId : UUID?,
    var latitude : Double,
    var longitude : Double,
    var postedBy : String?,
    var postedAt : LocalDateTime?,
    var expiresAt : LocalDateTime,
    var removedBy : String?,
    var removedAt : LocalDateTime?,
    var imageUrl : String?,
    var responsibleUsers : List<ResponsibleUsersDTO>,
    var status : String,
)
data class ResponsibleUsersDTO (
    var id : UUID,
    var name : String,
)
