package net.ipv64.kivop.dtos.MeetingServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class GetIdentityDTO (
    var id : UUID,
    var name : String,
)
