package net.ipv64.kivop.dtos.RideServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class CreateSpecialRideDTO (
    var name : String,
    var description : String?,
    var vehicleDescription : String?,
    var starts : LocalDateTime,
    var ends : LocalDateTime,
    var startLatitude : Float,
    var startLongitude : Float,
    var destinationLatitude : Float,
    var destinationLongitude : Float,
    var emptySeats : UByte,
)
