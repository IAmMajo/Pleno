package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class UpdatePosterPositionDTO (
    var latitude : Double?,
    var longitude : Double?,
    var isDisplayed : Boolean?,
    var imageBase64 : String?, // Optionaler Base64-String für das Bild
    var expiresAt :LocalDateTime
)
