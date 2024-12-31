package net.ipv64.kivop.dtos.RideServiceDTOs

import java.time.LocalDateTime
import java.util.UUID

data class GetRideOverviewDTO(
    var id: UUID?,
    var name: String,
    var description: String?,
    var starts: LocalDateTime,
    var latitude: Float,
    var longitude: Float,
)
