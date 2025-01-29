package net.ipv64.kivop.dtos.RideServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class GetEventRideDetailDTO (
    var id : UUID,
    var eventID : UUID,
    var eventName : String,
    var driverName : String,
    var driverID : UUID,
    var isSelfDriver : Boolean,
    var description : String?,
    var vehicleDescription : String?,
    var starts : LocalDateTime,
    var latitude : Float,
    var longitude : Float,
    var emptySeats : UByte,
    var riders : List<GetRiderDTO>,
)
