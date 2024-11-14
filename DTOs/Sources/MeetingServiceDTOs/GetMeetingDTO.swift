import Foundation

public struct GetMeetingDTO: Codable {
    public var id: UUID
    public var name: String
    public var description: String
    public var start: Date
    public var duration: UInt16?
    public var location: GetLocationDTO?
    public var chair: GetIdentityDTO?
    public var code: String?
}
