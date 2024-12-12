package net.ipv64.kivop.dtos.MeetingServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class GetVotingOptionDTO (
    var index : UByte,
    var text : String,
)
