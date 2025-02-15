import Foundation

public struct GetRecordDTO: Codable {
    public var meetingId: UUID
    public var lang: String
    public var identity: GetIdentityDTO
    public var status: RecordStatus
    public var content: String
    public var attendancesAppendix: String
    public var votingResultsAppendix: String?
    public var iAmTheRecorder: Bool
    
    public init(meetingId: UUID, lang: String, identity: GetIdentityDTO, status: RecordStatus, content: String, attendancesAppendix: String, votingResultsAppendix: String? = nil, iAmTheRecorder: Bool = false) {
        self.meetingId = meetingId
        self.lang = lang
        self.identity = identity
        self.status = status
        self.content = content
        self.attendancesAppendix = attendancesAppendix
        self.votingResultsAppendix = votingResultsAppendix
        self.iAmTheRecorder = iAmTheRecorder
    }
}

public enum RecordStatus: String, Codable, CaseIterable {
    case underway
    case submitted
    case approved
}
