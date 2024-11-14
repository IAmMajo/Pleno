import Foundation

public struct GetLocationDTO: Codable {
    public var id: UUID
    public var street: String
    public var number: String
    public var letter: Date
    public var postalCode: String?
    public var place: String?
    
    public init(id: UUID, street: String, number: String, letter: Date, postalCode: String? = nil, place: String? = nil) {
        self.id = id
        self.street = street
        self.number = number
        self.letter = letter
        self.postalCode = postalCode
        self.place = place
    }
}
