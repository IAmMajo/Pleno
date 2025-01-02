import Vapor
import Fluent
import Foundation
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class Fool: Model, @unchecked Sendable {
    
    static let schema = "fools"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "victim_id")
    var victim: Victim
    
    @Timestamp(key: "fooled_at", on: .create)
    var fooledAt: Date?
    
    init() { }
    
    init(id: UUID? = nil, victimId: UUID) {
        self.id = id
        self.$victim.id = victimId
    }
    
    convenience init(id: UUID? = nil, victim: Victim) throws {
        try self.init(id: id, victimId: victim.requireID())
    }
}

//extension [Fool] {
//    func toGetVictimDTO() throws -> GetVictimDTO {
//        guard let victimId = self.first?.victimId, let experiment = self.first?.experiment, self.allSatisfy({ fool in
//            fool.victimId == victimId && fool.experiment == experiment
//        }) else {
//            throw Abort(.internalServerError)
//        }
//        return self.reduce(.init(id: victimId, fooledCount: 0, fooledAt: [], experiment: experiment)) { partialResult, fool in
//                .init(id: partialResult.id, fooledCount: partialResult.fooledCount + 1, fooledAt: partialResult.fooledAt + [fool.fooledAt!], experiment: partialResult.experiment)
//        }
//    }
//    func toGetVictimDTOs() throws -> [GetVictimDTO] {
//        try self.grouped { fool in
//            fool.victimId
//        }
//        .map { (key: UUID, value: [Fool]) in
//            try value.toGetVictimDTO()
//        }
//    }
//}
