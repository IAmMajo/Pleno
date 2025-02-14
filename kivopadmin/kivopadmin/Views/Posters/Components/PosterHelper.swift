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



import SwiftUI
import PosterServiceDTOs

struct PosterHelper {
    static func getDateStatusText(position: PosterPositionResponseDTO) -> (text: String, color: Color) {
        let status = position.status
        switch status {
        case .hangs:
            if position.expiresAt < Calendar.current.date(byAdding: .day, value: 1, to: Date())! {
                return (text: "morgen überfällig", color: .orange)
            } else {
                return (text: "hängt", color: .blue)
            }
        case .takenDown:
            return (text: "abgehangen", color: .green)
        case .toHang:
            return (text: "hängt noch nicht", color: Color(UIColor.secondaryLabel))
        case .overdue:
            return (text: "überfällig", color: .red)
        case .damaged:
            return (text: "beschädigt", color: .orange)
        default:
            return (text: "", color: Color(UIColor.secondaryLabel))
        }
    }
    static func getFilterColor(for status: PosterPositionStatus) -> Color {
        switch status {
        case .toHang:
            return Color(UIColor.secondaryLabel)
        case .hangs:
            return .blue
        case .overdue:
            return .red
        case .takenDown:
            return .green
        case .damaged:
            return .orange
        }
    }
    
    // Funktion zur Auswahl des passenden Bildes je nach Status
    static func getImageForStatus(position: PosterPositionResponseDTO) -> Image {
        switch position.status {
        case .toHang:
            return Image(systemName: "xmark.circle")
        case .hangs:
            return Image(systemName: "photo.on.rectangle.angled")
        case .overdue:
            return Image(systemName: "exclamationmark.triangle.fill")
        case .takenDown:
            return Image(systemName: "checkmark.circle")
        case .damaged:
            return Image(systemName: "burst")
        }
    }
    
    static func getFilterIcon(for status: PosterPositionStatus) -> (symbol: String, color: Color) {
        switch status {
        case .toHang:
            return ("xmark.circle", Color(UIColor.secondaryLabel))
        case .hangs:
            return ("photo.on.rectangle.angled", .blue)
        case .overdue:
            return ("exclamationmark.triangle", .red)
        case .takenDown:
            return ("checkmark.circle", .green)
        case .damaged:
            return ("burst", .orange)
        default:
            return ("questionmark.circle", .gray) // Fallback für unbekannte Status
        }
    }
    
    

}
