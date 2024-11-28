import Foundation

public struct GetLocationDTO: Codable {
    public var id: UUID
    public var name: String
    public var street: String
    public var number: String
    public var letter: String
    public var postalCode: String?
    public var place: String?
    
    public init(id: UUID, name: String, street: String, number: String, letter: String, postalCode: String? = nil, place: String? = nil) {
        self.id = id
        self.name = name
        self.street = street
        self.number = number
        self.letter = letter
        self.postalCode = postalCode
        self.place = place
    }
}
