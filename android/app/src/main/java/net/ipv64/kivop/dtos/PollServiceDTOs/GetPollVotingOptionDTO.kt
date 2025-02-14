package net.ipv64.kivop.dtos.PollServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class GetPollVotingOptionDTO (
    var index : UByte,
    var text : String,
)
