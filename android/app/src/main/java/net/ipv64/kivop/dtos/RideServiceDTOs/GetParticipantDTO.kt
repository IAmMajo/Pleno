package net.ipv64.kivop.dtos.RideServiceDTOs

import java.util.UUID

data class GetParticipantDTO(
    var id: UUID?,
    var name: String,
    var driver: Boolean,
    var passengers_count: Int?,
    var latitude: Float,
    var longitude: Float,
    var itsMe: Boolean,
)
