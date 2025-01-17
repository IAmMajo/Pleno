package net.ipv64.kivop.dtos.PosterServiceDTOs

data class UpdatePosterDTO(
    var name: String?,
    var description: String?,
    var image: ByteArray?,
)
