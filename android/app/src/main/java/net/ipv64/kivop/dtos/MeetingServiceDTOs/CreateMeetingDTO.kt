package net.ipv64.kivop.dtos.MeetingServiceDTOs

import java.util.UUID

import java.time.LocalDateTime

data class CreateMeetingDTO (
    var name : String,
    var description : String?,
    var start : LocalDateTime,
    var duration : UShort?,
    var locationId : UUID?,
    var location : CreateLocationDTO?,
)
