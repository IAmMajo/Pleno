package net.ipv64.kivop.dtos

data class GetVotingDTO (
    var id : Uuid
    var meetingId : Uuid
    var question : String
    var description : String
    var isOpen : Boolean
    var startedAt : Date?
    var closedAt : Date?
    var anonymous : Boolean
    var options : List<GetVotingOptionDTO>
)
