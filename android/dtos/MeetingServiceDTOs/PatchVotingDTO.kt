public data class PatchVotingDTO {
    public var question : String?
    public var anonymous : Boolean?
    public var options : List<GetVotingOptionDTO>? // If options is not nil: ALL previous options will be deleted/replaced
}
