public data class GetAttendanceDTO {
    public var meetingId : Uuid
    public var identity : GetIdentityDTO
    public var status : AttendanceStatus
}
public enum class AttendanceStatus {
    present,
    absent,
    accepted,
}
