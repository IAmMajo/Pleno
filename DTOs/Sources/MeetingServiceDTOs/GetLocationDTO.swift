import Foundation

public struct GetLocationDTO: Codable {
    public var id: UUID
    public var street: String
    public var number: String
    public var letter: Date
    public var postalCode: String?
    public var place: String?
}
