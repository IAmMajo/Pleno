package net.ipv64.kivop.dtos.RideServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class GetRideDetailDTO (
    var id : UUID?,
    var name : String,
    var description : String?,
    var starts : LocalDateTime,
    var participants : List<GetParticipantDTO>,
    var latitude : Float,
    var longitude : Float,
    var participantsSum : Int,
    var seatsSum : Int,
    var passengersSum : Int,
)
