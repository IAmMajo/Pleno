public data class CreateVotingDTO {
    public var meetingId : Uuid
    public var question : String
    public var anonymous : Boolean
    public var options : List<GetVotingOptionDTO>
}
