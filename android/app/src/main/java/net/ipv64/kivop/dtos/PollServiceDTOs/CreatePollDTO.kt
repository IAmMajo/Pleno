package net.ipv64.kivop.dtos.PollServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class CreatePollDTO (
    var question : String,
    var description : String?,
    var closedAt : LocalDateTime,
    var anonymous : Boolean,
    var multiSelect : Boolean,
    var options : List<GetPollVotingOptionDTO>,
)
