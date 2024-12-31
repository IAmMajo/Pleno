package net.ipv64.kivop.dtos.RideServiceDTOs

import java.time.LocalDateTime
import java.util.UUID

data class GetRideDetailDTO(
    var id: UUID?,
    var name: String,
    var description: String?,
    var starts: LocalDateTime,
    var participants: List<GetParticipantDTO>,
    var latitude: Float,
    var longitude: Float,
    var participantsSum: Int,
    var seatsSum: Int,
    var passengersSum: Int,
)
