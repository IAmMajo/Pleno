import Foundation

public struct CreateLocationDTO: Codable {
    public var street: String
    public var number: String?
    public var letter: Date?
    public var postalCode: String?
    public var place: String?
}
