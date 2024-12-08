import Models
import MeetingServiceDTOs

extension Models.AttendanceStatus {
    public func convert() -> MeetingServiceDTOs.AttendanceStatus {
        .init(rawValue: self.rawValue)!
    }
}
