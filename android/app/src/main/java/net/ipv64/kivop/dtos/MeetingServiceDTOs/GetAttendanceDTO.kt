package net.ipv64.kivop.dtos.MeetingServiceDTOs

import java.util.UUID

data class GetAttendanceDTO(
    var meetingId: UUID,
    var identity: GetIdentityDTO,
    var status: AttendanceStatus?,
    var itsame: Boolean, // it's-a me
)

enum class AttendanceStatus {
  present,
  absent,
  accepted,
}
