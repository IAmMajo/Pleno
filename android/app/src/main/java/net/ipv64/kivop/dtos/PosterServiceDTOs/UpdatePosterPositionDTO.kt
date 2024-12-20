package net.ipv64.kivop.dtos.PosterServiceDTOs



import java.time.LocalDateTime
import java.util.UUID

data class UpdatePosterPositionDTO(
    var posterId: UUID?,
    var latitude: Double?,
    var longitude: Double?,
    var expiresAt: LocalDateTime?,
    var responsibleUsers: List<UUID>?,
    var image: ByteArray?,
)