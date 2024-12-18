import Vapor
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
    
    @Enum(key: "experiment")
    var experiment: Experiment
    
    @Children(for: \.$victim)
    var fools: [Fool]
    
    init() { }
    
    init(id: UUID? = nil, experiment: Experiment) {
        self.id = id
        self.experiment = experiment
    }
}

enum Experiment: String, Codable {
    case labyrinth
    case briefkasten
}

extension Victim {
    func toGetVictimDTO() throws -> GetVictimDTO {
        try .init(id: self.requireID(), fooledCount: self.fools.count, fooledAt: self.fools.map({ fool in
            fool.fooledAt!
        }), experiment: self.experiment)
    }
}

extension [Victim] {
    func toGetVictimDTO() throws -> [GetVictimDTO] {
        try self.map { victim throws in
            try victim.toGetVictimDTO()
        }
    }
}
