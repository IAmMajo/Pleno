package net.ipv64.kivop.dtos

data class CreateVotingDTO (
    var meetingId : UUID,
    var question : String,
    var description : String?,
    var anonymous : Boolean,
    var options : List<GetVotingOptionDTO>,
)
