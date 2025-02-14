package net.ipv64.kivop.dtos.PollServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class GetPollDTO (
    var id : UUID,
    var question : String,
    var description : String,
    var startedAt : LocalDateTime,
    var closedAt : LocalDateTime,
    var anonymous : Boolean,
    var multiSelect : Boolean,
    var iVoted : Boolean,
    var isOpen : Boolean,
    var options : List<GetPollVotingOptionDTO>,
)
