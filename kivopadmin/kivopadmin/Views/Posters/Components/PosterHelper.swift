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
