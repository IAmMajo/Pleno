package net.ipv64.kivop.dtos.RideServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class GetEventRideDTO (
    var id : UUID,
    var eventID : UUID,
    var eventName : String,
    var driverName : String,
    var driverID : UUID,
    var starts : LocalDateTime,
    var latitude : Float,
    var longitude : Float,
    var emptySeats : UByte,
    var allocatedSeats : UByte,
    var myState : UsersRideState,
    var openRequests : Int?,
)
