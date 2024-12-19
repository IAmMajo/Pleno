package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class PosterPositionResponseDTO (
    var id : UUID?,
    var posterId : UUID,
    var responsibleUserId : UUID,
    var latitude : Double,
    var longitude : Double,
    var isDisplayed : Boolean,
    var imageBase64 : String, // Hinzugefügt
    var expiresAt :LocalDateTime,
    var postedAt :LocalDateTime
)
