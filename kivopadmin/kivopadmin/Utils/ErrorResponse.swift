// This file is licensed under the MIT-0 License.

import Foundation

// Fehlerstruktur für das JSON-Fehlermodell
struct ErrorResponse: Codable {
    let error: Bool
    let reason: String
}
