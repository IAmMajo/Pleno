package net.ipv64.kivop.dtos.MeetingServiceDTOs

import java.util.UUID

import java.time.LocalDateTime

data class GetMeetingDTO (
    var id : UUID,
    var name : String,
    var description : String,
    var status : MeetingStatus, 
    var start : LocalDateTime,
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
