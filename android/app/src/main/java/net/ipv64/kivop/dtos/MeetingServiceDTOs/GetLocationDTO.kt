package net.ipv64.kivop.dtos.MeetingServiceDTOs

import java.util.UUID

data class GetLocationDTO(
    var id: UUID,
    var name: String,
    var street: String,
    var number: String,
    var letter: String,
    var postalCode: String?,
    var place: String?,
)
