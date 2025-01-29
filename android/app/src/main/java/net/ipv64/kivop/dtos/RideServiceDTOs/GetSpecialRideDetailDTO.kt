package net.ipv64.kivop.dtos.RideServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

//import Foundation 
data class GetSpecialRideDetailDTO (
    var id : UUID,
    var driverName : String,
    var driverID : UUID,
    var isSelfDriver : Boolean,
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
    var riders : List<GetRiderDTO>,
)
