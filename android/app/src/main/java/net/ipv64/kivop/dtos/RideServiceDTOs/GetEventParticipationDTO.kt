package net.ipv64.kivop.dtos.RideServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class GetEventParticipationDTO (
    var id : UUID,
    var name : String,
    var itsMe : Boolean,
    var participates : UsersParticipationState,
)
enum class UsersParticipationState {
    nothing,
    absent,
    present,
}
