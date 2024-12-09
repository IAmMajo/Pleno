package net.ipv64.kivop.dtos

data class GetVotingDTO (
    var id : UUID,
    var meetingId : UUID,
    var question : String,
    var description : String,
    var isOpen : Boolean,
    var startedAt : Date?,
    var closedAt : Date?,
    var anonymous : Boolean,
    var options : List<GetVotingOptionDTO>,
)
