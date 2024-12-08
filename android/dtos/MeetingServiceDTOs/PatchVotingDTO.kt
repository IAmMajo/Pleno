package net.ipv64.kivop.dtos

data class PatchVotingDTO (
    var question : String?
    var description : String?
    var anonymous : Boolean?
    var options : List<GetVotingOptionDTO>? // If options is not nil: ALL previous options will be deleted/replaced
)
