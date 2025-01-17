package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID

data class PosterResponseDTO(
    var id: UUID,
    var name: String,
    var description: String?,
    var imageUrl: String,
)
