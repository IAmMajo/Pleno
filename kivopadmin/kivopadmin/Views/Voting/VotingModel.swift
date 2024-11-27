import Foundation

struct Voting: Identifiable, Hashable, Equatable {
    let id: UUID
    var title: String
    var options: [String]
    var results: [Int]
    var isOpen: Bool
    var createdAt: Date
}

