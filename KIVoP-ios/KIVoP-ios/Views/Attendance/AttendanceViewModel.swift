import Foundation
import SwiftUI
import MeetingServiceDTOs

class AttendanceViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedTab: Int = 0
    @Published var meetings: [GetMeetingDTO] = exampleMeetings

    static let exampleMeetings: [GetMeetingDTO] = [
        GetMeetingDTO(id: UUID(), name: "Jahreshauptversammlung", description: "Beschreibung", status: .inSession, start: Date()),
        GetMeetingDTO(id: UUID(), name: "Treffen 1", description: "Beschreibung", status: .completed, start: Calendar.current.date(byAdding: .day, value: -10, to: Date())!),
        GetMeetingDTO(id: UUID(), name: "Treffen 2", description: "Beschreibung", status: .completed, start: Calendar.current.date(byAdding: .day, value: -20, to: Date())!),
        GetMeetingDTO(id: UUID(), name: "Treffen 3", description: "Beschreibung", status: .completed, start: Calendar.current.date(byAdding: .month, value: -1, to: Date())!),
        GetMeetingDTO(id: UUID(), name: "Planungs-Meeting", description: "Beschreibung", status: .scheduled, start: Calendar.current.date(byAdding: .day, value: 10, to: Date())!),
        GetMeetingDTO(id: UUID(), name: "Feedback-Runde", description: "Beschreibung", status: .scheduled, start: Calendar.current.date(byAdding: .day, value: 20, to: Date())!)
    ]
    
    
    // Abruf der Meetings von der API
    func loadMeetingsFromAPI() {
        guard let url = URL(string: "https://kivop.ipv64.net/meetings") else {
            print("Ungültige URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Fehler beim Abrufen der Daten: \(error)")
                return
            }

            guard let data = data else {
                print("Keine Daten erhalten")
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let fetchedMeetings = try decoder.decode([GetMeetingDTO].self, from: data)

                DispatchQueue.main.async {
                    self?.meetings.append(contentsOf: fetchedMeetings)
                }
            } catch {
                print("Fehler beim Dekodieren der Daten: \(error)")
            }
        }.resume()
    }
    
    // Aktuelle Sitzung (falls vorhanden)
    var currentMeeting: GetMeetingDTO? {
        meetings.first(where: { $0.status == .inSession })
    }

    // Gruppiert die Sitzungen nach Monat und Jahr
    var groupedMeetings: [Dictionary<String, [GetMeetingDTO]>.Element] {
        let filtered = filteredMeetings()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM - yyyy"

        // Gruppierung
        var grouped = Dictionary(grouping: filtered) { meeting in
            dateFormatter.string(from: meeting.start)
        }

        // Sortierung innerhalb der Gruppen
        for (key, meetings) in grouped {
            grouped[key] = meetings.sorted { lhs, rhs in
                if selectedTab == 0 {
                    return lhs.start > rhs.start // Vergangene: Absteigend
                } else {
                    return lhs.start < rhs.start // Anstehende: Aufsteigend
                }
            }
        }

        // Sortierung der Gruppen
        return grouped.sorted { lhs, rhs in
            guard let lhsDate = dateFormatter.date(from: lhs.key),
                  let rhsDate = dateFormatter.date(from: rhs.key) else {
                return lhs.key < rhs.key
            }
            return selectedTab == 0 ? lhsDate > rhsDate : lhsDate < rhsDate
        }
    }

    // Filtert Sitzungen basierend auf dem Tab
    private func filteredMeetings() -> [GetMeetingDTO] {
        let now = Date()
        switch selectedTab {
        case 0:
            return meetings.filter { $0.start < now && $0.status == .completed }
        case 1:
            return meetings.filter { $0.start > now && $0.status == .scheduled }
        default:
            return []
        }
    }
}
