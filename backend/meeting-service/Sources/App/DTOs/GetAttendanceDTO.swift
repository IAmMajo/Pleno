import Vapor
import MeetingServiceDTOs

extension GetAttendanceDTO: @retroactive Content, @unchecked @retroactive Sendable { }

extension AttendanceStatus?: @retroactive Comparable {
    private var sortOrder: Int {
        switch self {
        case .present:
            return 0
        case .accepted:
            return 1
        case nil:
            return 2
        case .absent:
            return 3
        }
    }
    
    public static func ==(lhs: AttendanceStatus?, rhs: AttendanceStatus?) -> Bool {
        return lhs.sortOrder == rhs.sortOrder
    }
    
    public static func <(lhs: AttendanceStatus?, rhs: AttendanceStatus?) -> Bool {
        return lhs.sortOrder < rhs.sortOrder
    }
}
