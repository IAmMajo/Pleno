import Fluent
import Foundation
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
public final class Place: Model, @unchecked Sendable {
    public static let schema = "places"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "postal_code")
    public var postalCode: String
    
    @Field(key: "place")
    public var place: String
    
    @Children(for: \.$place)
    public var locations: [Location]

    public init() { }
    
    public init(id: UUID? = nil, postalCode: String, place: String) {
        self.id = id
        self.postalCode = postalCode
        self.place = place
    }
}
