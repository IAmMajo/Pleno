import Foundation

public struct CreateMeetingDTO: Codable {
    public var name: String
    public var description: String?
    public var start: Date
    public var duration: UInt16?
    public var locationId: UUID?
    public var location: CreateLocationDTO?
    
    public init(name: String, description: String? = nil, start: Date, duration: UInt16? = nil, locationId: UUID? = nil, location: CreateLocationDTO? = nil) {
        self.name = name
        self.description = description
        self.start = start
        self.duration = duration
        self.locationId = locationId
        self.location = location
    }
}
