package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class CreatePosterPositionDTO (
    var posterId : UUID,
    var responsibleUserId : UUID,
    var latitude : Double,
    var longitude : Double,
    var imageBase64 : String, // Bild als Base64-String
    var expiresAt : LocalDateTime
)
