package net.ipv64.kivop.dtos

data class CreateMeetingDTO (
    var name : String,
    var description : String?,
    var start : Date,
    var duration : UShort?,
    var locationId : UUID?,
    var location : CreateLocationDTO?,
)
