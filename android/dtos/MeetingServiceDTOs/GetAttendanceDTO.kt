package net.ipv64.kivop.dtos

data class GetAttendanceDTO (
    var meetingId : Uuid
    var identity : GetIdentityDTO
    var status : AttendanceStatus?
    var itsame : Boolean // it's-a me
)
public enum class AttendanceStatus {
    present,
    absent,
    accepted,
)
