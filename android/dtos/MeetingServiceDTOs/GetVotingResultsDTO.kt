package net.ipv64.kivop.dtos

data class GetVotingResultsDTO (
    var votingId : UUID,
    var myVote : UByte?, // Index 0: Abstention | nil: did not vote at all
    var results : List<GetVotingResultDTO>,
)
data class GetVotingResultDTO (
    var index : UByte, // Index 0: Abstention
    var total : UByte,
    var percentage : Double,
    var identities : List<GetIdentityDTO>?,
)
