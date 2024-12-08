package net.ipv64.kivop.dtos

data class CreateVotingDTO (
    var meetingId : Uuid
    var question : String
    var description : String?
    var anonymous : Boolean
    var options : List<GetVotingOptionDTO>
)
