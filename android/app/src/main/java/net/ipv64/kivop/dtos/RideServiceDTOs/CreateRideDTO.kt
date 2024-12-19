package net.ipv64.kivop.dtos.RideServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class CreateRideDTO (
    var name : String,
    var description : String?,
    var starts : LocalDateTime,
    var latitude : Float,
    var longitude : Float,
)
