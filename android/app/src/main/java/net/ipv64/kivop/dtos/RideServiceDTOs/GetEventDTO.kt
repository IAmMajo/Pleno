package net.ipv64.kivop.dtos.RideServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class GetEventDTO (
    var id : UUID,
    var name : String,
    var starts : LocalDateTime,
    var ends : LocalDateTime,
    var myState : UsersEventState,
)
enum class UsersEventState {
    nothing,
    absent,
    present,
}
