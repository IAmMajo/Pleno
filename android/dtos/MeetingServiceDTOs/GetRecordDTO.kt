public data class GetRecordDTO {
    public var meetingId : Uuid
    public var lang : String
    public var identity : GetIdentityDTO
    public var status : RecordStatus
    public var content : String
}
public enum class RecordStatus {
    underway,
    submitted,
    approved,
}
