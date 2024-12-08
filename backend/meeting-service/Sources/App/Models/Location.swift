import Models
import MeetingServiceDTOs

extension Location {
    public func toGetLocationDTO() throws -> GetLocationDTO {
        .init(id: try self.requireID(), name: self.name, street: self.street, number: self.number, letter: self.letter, postalCode: self.place?.postalCode, place: self.place?.place)
    }
}
