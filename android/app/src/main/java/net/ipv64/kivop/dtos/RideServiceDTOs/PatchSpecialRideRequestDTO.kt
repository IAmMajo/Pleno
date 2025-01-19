package net.ipv64.kivop.dtos.RideServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class PatchSpecialRideRequestDTO (
    var latitude : Float?,
    var longitude : Float?,
    var accepted : Boolean?,
)
