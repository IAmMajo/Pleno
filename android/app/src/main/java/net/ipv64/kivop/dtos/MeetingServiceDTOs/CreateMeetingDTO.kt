package net.ipv64.kivop.dtos.MeetingServiceDTOs

import java.time.LocalDateTime
import java.util.UUID

data class CreateMeetingDTO(
    var name: String,
    var description: String?,
    var start: LocalDateTime,
    var duration: UShort?,
    var locationId: UUID?,
    var location: CreateLocationDTO?,
)
