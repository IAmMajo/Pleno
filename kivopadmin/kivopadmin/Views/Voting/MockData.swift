import Foundation

var mockVotings = [
    Voting(
        id: UUID(),
        title: "Beste Programmiersprache",
        options: ["Swift", "Python", "C++"],
        results: [5, 8, 2],
        isOpen: true,
        createdAt: Date()
    ),
    Voting(
        id: UUID(),
        title: "Lieblingsfarbe",
        options: ["Rot", "Blau", "Grün"],
        results: [3, 6, 1],
        isOpen: false,
        createdAt: Date().addingTimeInterval(-86400)
    )
]

