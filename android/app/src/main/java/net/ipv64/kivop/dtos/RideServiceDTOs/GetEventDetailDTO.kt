package net.ipv64.kivop.dtos.RideServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class GetEventDetailDTO (
    var id : UUID,
    var name : String,
    var description : String?,
    var starts : LocalDateTime,
    var ends : LocalDateTime,
    var latitude : Float,
    var longitude : Float,
    var participations : List<GetEventParticipationDTO>,
    var userWithoutFeedback : List<GetUserWithoutFeedbackDTO>,
)
