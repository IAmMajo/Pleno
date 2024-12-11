package net.ipv64.kivop.dtos.MeetingServiceDTOs

import java.util.UUID

import java.time.LocalDateTime

data class PatchRecordDTO (
    var identityId : UUID?,
    var content : String?,
)
