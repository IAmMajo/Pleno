import Models
import MeetingServiceDTOs

extension Models.MeetingStatus {
    public func convert() -> MeetingServiceDTOs.MeetingStatus {
        .init(rawValue: self.rawValue)!
    }
}
