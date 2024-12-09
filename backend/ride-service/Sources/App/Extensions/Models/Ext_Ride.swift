import Models

extension Ride {
    public func toGetRideOverviewDTO() throws -> GetRideOverviewDTO {
        return .init(id: self.id, name: self.name, description: self.description, starts: self.starts)
    }
}
