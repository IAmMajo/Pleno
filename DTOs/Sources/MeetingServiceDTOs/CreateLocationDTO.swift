import Foundation

public struct CreateLocationDTO: Codable {
    public var street: String
    public var number: String?
    public var letter: Date?
    public var postalCode: String?
    public var place: String?
    
    public init(street: String, number: String? = nil, letter: Date? = nil, postalCode: String? = nil, place: String? = nil) {
        self.street = street
        self.number = number
        self.letter = letter
        self.postalCode = postalCode
        self.place = place
    }
}
