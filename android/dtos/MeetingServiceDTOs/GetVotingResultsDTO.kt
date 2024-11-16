public data class GetVotingResultsDTO {
    public var votingId : Uuid
    public var results : List<GetVotingResultDTO>
}
public data class GetVotingResultDTO {
    public var index : UByte // Index 0: Abstention
    public var total : UByte
    public var percentage : Double
    public var identities : List<GetIdentityDTO>?
}
