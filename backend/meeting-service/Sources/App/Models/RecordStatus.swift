import Models
import MeetingServiceDTOs

extension Models.RecordStatus {
    public func convert() -> MeetingServiceDTOs.RecordStatus {
        .init(rawValue: self.rawValue)!
    }
}
