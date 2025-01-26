package net.ipv64.kivop.dtos.RideServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class PatchEventRideDTO (
    var description : String?,
    var vehicleDescription : String?,
    var starts : LocalDateTime?,
    var latitude : Float?,
    var longitude : Float?,
    var emptySeats : UByte?,
)
