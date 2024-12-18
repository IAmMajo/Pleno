import Vapor

struct GetVictimDTO: Content {
    var id: UUID
    var fooledCount: Int
    var fooledAt: [Date] = []
    var experiment: Experiment
}
