// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



import Foundation
import PosterServiceDTOs
import SwiftUI

// Eigene Datenstruktur, die eine Plakatposition mit der zugehörigen Adresse und dem zugehörigen Bild vereint
struct PosterPositionWithAddress: Equatable, Identifiable {
    let position: PosterPositionResponseDTO
    let address: String
    var image: Data? // Optionales Bild-Datenfeld

    // Identifiable-Konformität durch Verwendung von position.id
    var id: UUID {
        return position.id
    }

    // Equatable-Protokoll
    static func == (lhs: PosterPositionWithAddress, rhs: PosterPositionWithAddress) -> Bool {
        return lhs.position.id == rhs.position.id &&
               lhs.address == rhs.address &&
               lhs.image == rhs.image // Vergleicht auch das Bild (falls vorhanden)
    }
}

extension PosterPositionWithAddress {
    var color: Color {
        switch position.status {
        case .toHang: return .orange
        case .overdue: return .red
        case .hangs: return .green
        case .takenDown: return .gray
        case .damaged: return .orange
        default: return .blue
        }
    }
}
