public data class GetVotingDTO {
    public var id : Uuid
    public var meetingId : Uuid
    public var question : String
    public var description : String
    public var isOpen : Boolean
    public var startedAt : Date?
    public var closedAt : Date?
    public var anonymous : Boolean
    public var options : List<GetVotingOptionDTO>
}
