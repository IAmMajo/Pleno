package net.ipv64.kivop.dtos

data class GetRecordDTO (
    var meetingId : Uuid
    var lang : String
    var identity : GetIdentityDTO
    var status : RecordStatus
    var content : String
)
public enum class RecordStatus {
    underway,
    submitted,
    approved,
)
