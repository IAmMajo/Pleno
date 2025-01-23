import Foundation
import PosterServiceDTOs
import SwiftUI

struct PosterPositionWithAddress: Equatable, Identifiable {
    let position: PosterPositionResponseDTO
    let address: String

    // Identifiable-Konformität durch Verwendung von position.id
    var id: UUID {
        return position.id
    }

    // Equatable-Protokoll
    static func == (lhs: PosterPositionWithAddress, rhs: PosterPositionWithAddress) -> Bool {
        return lhs.position.id == rhs.position.id &&
               lhs.address == rhs.address
    }
}

extension PosterPositionWithAddress {
    var color: Color {
        switch position.status {
        case "toHang": return .orange
        case "overdue": return .red
        case "hangs": return .green
        case "takenDown": return .gray
        default: return .blue
        }
    }
}
