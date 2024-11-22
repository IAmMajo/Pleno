import Foundation

public struct CreateLocationDTO: Codable {
    public var name: String
    public var street: String?
    public var number: String?
    public var letter: String?
    public var postalCode: String?
    public var place: String?
    
    public init(name: String, street: String? = nil, number: String? = nil, letter: String? = nil, postalCode: String? = nil, place: String? = nil) {
        self.name = name
        self.street = street
        self.number = number
        self.letter = letter
        self.postalCode = postalCode
        self.place = place
    }
}
