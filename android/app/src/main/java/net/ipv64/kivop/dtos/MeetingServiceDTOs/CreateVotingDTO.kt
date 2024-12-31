package net.ipv64.kivop.dtos.MeetingServiceDTOs

import java.util.UUID

data class CreateVotingDTO(
    var meetingId: UUID,
    var question: String,
    var description: String?,
    var anonymous: Boolean,
    var options: List<GetVotingOptionDTO>,
)
