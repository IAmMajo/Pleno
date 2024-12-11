package net.ipv64.kivop.dtos.MeetingServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class GetRecordDTO (
    var meetingId : UUID,
    var lang : String,
    var identity : GetIdentityDTO,
    var status : RecordStatus,
    var content : String,
)
enum class RecordStatus {
    underway,
    submitted,
    approved,
}
