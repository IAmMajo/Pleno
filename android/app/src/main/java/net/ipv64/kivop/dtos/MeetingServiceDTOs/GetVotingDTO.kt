package net.ipv64.kivop.dtos.MeetingServiceDTOs

import java.util.UUID

import java.time.LocalDateTime

data class GetVotingDTO (
    var id : UUID,
    var meetingId : UUID,
    var question : String,
    var description : String,
    var isOpen : Boolean,
    var startedAt : LocalDateTime?,
    var closedAt : LocalDateTime?,
    var anonymous : Boolean,
    var options : List<GetVotingOptionDTO>,
)
