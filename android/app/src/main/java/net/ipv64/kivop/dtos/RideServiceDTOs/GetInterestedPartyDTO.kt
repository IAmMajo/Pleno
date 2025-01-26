package net.ipv64.kivop.dtos.RideServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class GetInterestedPartyDTO (
    var id : UUID,
    var eventName : String,
    var latitude : Float,
    var longitude : Float,
)
