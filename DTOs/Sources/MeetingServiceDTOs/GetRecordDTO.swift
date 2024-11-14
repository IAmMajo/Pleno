import Foundation

public struct GetRecordDTO: Codable {
    public var meetingId: UUID
    public var lang: String
    public var identity: GetIdentityDTO
    public var status: RecordStatus
    public var content: String
    
    public init(meetingId: UUID, lang: String, identity: GetIdentityDTO, status: RecordStatus, content: String) {
        self.meetingId = meetingId
        self.lang = lang
        self.identity = identity
        self.status = status
        self.content = content
    }
}

public enum RecordStatus: String, Codable {
    case underway
    case submitted
    case approved
}
