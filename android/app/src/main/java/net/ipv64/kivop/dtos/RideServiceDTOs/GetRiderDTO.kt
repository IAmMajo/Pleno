package net.ipv64.kivop.dtos.RideServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class GetRiderDTO (
    var id : UUID,
    var username : String,
    var latitude : Float,
    var longitude : Float,
    var istMe : Boolean,
    var accepted : Boolean,
)
