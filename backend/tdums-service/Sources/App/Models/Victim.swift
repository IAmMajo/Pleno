import Fluent
import Foundation
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class Victim: Model, @unchecked Sendable {
    
    static let schema = "victims"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "count")
    var count: UInt8
    
    @Field(key: "experiment")
    var experiment: Experiment
    
    @Field(key: "unused")
    var unused: Bool
    
    init() { }
    
    init(id: UUID? = nil, count: UInt8 = 0, experiment: Experiment) {
        self.id = id
        self.count = count
        self.experiment = experiment
        self.unused = false
    }
}

enum Experiment: String, Codable {
    case weihnachtsmarkt
    case mensa
    case briefkasten
}
