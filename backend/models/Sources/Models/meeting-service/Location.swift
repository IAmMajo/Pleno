import Fluent
import Foundation
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
public final class Location: Model, @unchecked Sendable {
    public static let schema = "locations"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "name")
    public var name: String
    
    @Field(key: "street")
    public var street: String
    
    @Field(key: "number")
    public var number: String
    
    @Field(key: "letter")
    public var letter: String
    
    @OptionalParent(key: "place_id")
    public var place: Place?
    
    @Children(for: \.$location)
    public var meetings: [Meeting]

    public init() { }
    
    public init(id: UUID? = nil, name: String, street: String, number: String, letter: String, placeId: Place.IDValue? = nil) {
        self.id = id
        self.name = name
        self.street = street
        self.number = number
        self.letter = letter
        self.$place.id = placeId
    }
}
