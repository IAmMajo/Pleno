package net.ipv64.kivop.dtos.RideServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class CreateInterestedPartyDTO (
    var eventID : UUID,
    var latitude : Float,
    var longitude : Float,
)
