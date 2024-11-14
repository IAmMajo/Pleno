import Foundation

public struct GetRecordDTO: Codable {
    public var meetingId: UUID
    public var lang: String
    public var identity: GetIdentityDTO
    public var status: RecordStatus
    public var content: String
}

public enum RecordStatus: String, Codable {
    case underway
    case submitted
    case approved
}
