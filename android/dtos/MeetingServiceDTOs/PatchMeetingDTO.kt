public data class PatchMeetingDTO {
    public var name : String?
    public var description : String?
    public var start : Date?
    public var duration : UShort?
    public var locationId : Uuid?
    public var location : CreateLocationDTO?
}
