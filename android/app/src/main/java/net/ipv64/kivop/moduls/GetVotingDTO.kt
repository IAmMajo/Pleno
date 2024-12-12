package net.ipv64.kivop.moduls

import java.util.UUID

data class GetVotingDTO (
     var id : UUID,
     var meetingId : UUID,
     var question : String,
     var description : String,
     var isOpen : Boolean,
     var startedAt : String?,
     var closedAt : String?,
     var anonymous : Boolean,
     var options : List<GetVotingOptionDTO>,
)
//todo: Change with dots