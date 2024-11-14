import Foundation

public struct PatchMeetingDTO: Codable {
    public var name: String?
    public var description: String?
    public var start: Date?
    public var duration: UInt16?
    public var locationId: UUID?
    public var location: CreateLocationDTO?
}
