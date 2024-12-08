package net.ipv64.kivop.dtos

data class PatchMeetingDTO (
    var name : String?
    var description : String?
    var start : Date?
    var duration : UShort?
    var locationId : Uuid?
    var location : CreateLocationDTO?
)
