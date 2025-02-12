import Foundation

// Fehlerstruktur für das JSON-Fehlermodell
struct ErrorResponse: Codable {
    let error: Bool
    let reason: String
}
