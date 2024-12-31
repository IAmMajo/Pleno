package net.ipv64.kivop.dtos.PosterServiceDTOs

import java.util.UUID

data class TakeDownPosterPositionDTO(
    var posterPosition: UUID,
    var image: ByteArray,
)
