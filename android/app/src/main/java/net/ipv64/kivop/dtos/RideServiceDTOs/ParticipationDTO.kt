package net.ipv64.kivop.dtos.RideServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class ParticipationDTO (
    var driver : Boolean,
    var passengers_count : Int?,
    var latitude : Float,
    var longitude : Float,
)
