package net.ipv64.kivop.dtos

data class GetMeetingDTO (
    var id : UUID,
    var name : String,
    var description : String,
    var status : MeetingStatus, 
    var start : Date,
    var duration : UShort?,
    var location : GetLocationDTO?,
    var chair : GetIdentityDTO?,
    var code : String?,
    var myAttendanceStatus : AttendanceStatus?,
)
enum class MeetingStatus {
    scheduled,
    inSession,
    completed,
}
