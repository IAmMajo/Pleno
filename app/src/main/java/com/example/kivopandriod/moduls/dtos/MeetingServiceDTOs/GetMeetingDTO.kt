public data class GetMeetingDTO {
    public var id : Uuid
    public var name : String
    public var description : String
    public var status : MeetingStatus 
    public var start : Date
    public var duration : UShort?
    public var location : GetLocationDTO?
    public var chair : GetIdentityDTO?
    public var code : String?
}
public enum class MeetingStatus {
    scheduled,
    inSession,
    completed,
}
