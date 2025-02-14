package net.ipv64.kivop.dtos.PollServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class GetPollResultsDTO (
    var myVotes : List<UByte>, // empty: did not vote at all
    var totalCount : UInt,
    var identityCount : UInt,
    var results : List<GetPollResultDTO>,
)
data class GetPollResultDTO (
    var index : UByte,
    var text : String,
    var count : UInt,
    var percentage : Double,
    var identities : List<GetIdentityDTO>?,
)
