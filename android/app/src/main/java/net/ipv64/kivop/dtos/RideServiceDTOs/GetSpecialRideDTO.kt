package net.ipv64.kivop.dtos.RideServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class GetSpecialRideDTO (
    var id : UUID?,
    var name : String,
    var starts : LocalDateTime,
    var ends : LocalDateTime,
    var emptySeats : UByte,
    var allocatedSeats : UByte,
    var myState : UsersSpecialRideState,
)
enum class UsersSpecialRideState {
    nothing,
    requested,
    accepted,
    driver,
}
