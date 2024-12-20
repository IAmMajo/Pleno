package net.ipv64.kivop.dtos.RideServiceDTOs

import java.time.LocalDateTime

data class PatchRideDTO(
    var name: String?,
    var description: String?,
    var starts: LocalDateTime?,
    var latitude: Float?,
    var longitude: Float?,
)
