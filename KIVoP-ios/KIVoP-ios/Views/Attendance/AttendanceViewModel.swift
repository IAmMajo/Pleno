//
//  AttendanceViewModel.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 25.11.24.
//

import Foundation
import SwiftUI
import MeetingServiceDTOs

class AttendanceViewModel: ObservableObject {

    @Published var searchText: String = ""
    @Published var selectedTab: Int = 0
    @Published var meetings: [GetMeetingDTO] = []
    
    init() {
        fetchMeetings()
    }
    
    // Abruf der Meetings von der API
    func fetchMeetings() {
        Task {
            do {
                // Statischer Login zum Testen, bis die Funktion implementiert wurde.
                try await AuthController.shared.login(email: "henrik.peltzer@gmail.com", password: "Test123")
                let token = try await AuthController.shared.getAuthToken()
                
                // Meetings abrufen
                guard let url = URL(string: "https://kivop.ipv64.net/meetings") else {
                    throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw NSError(domain: "Failed to fetch meetings", code: 500, userInfo: nil)
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    // Die Dekodierung und die Fehlerbehandlung innerhalb der Hauptwarteschlange
                    DispatchQueue.main.async {
                        do {
                            let fetchedMeetings = try decoder.decode([GetMeetingDTO].self, from: data)
                            self.meetings.append(contentsOf: fetchedMeetings)
                        } catch {
                            print("Fehler beim Dekodieren der Meetings: \(error.localizedDescription)")
                        }
                    }
                }
            } catch {
                // Fehlerbehandlung auf dem Hauptthread
                DispatchQueue.main.async {
                    print("\(error.localizedDescription)")
                }
            }
        }
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
        switch selectedTab {
        case 0:
            return meetings.filter { $0.status == .completed }
        case 1:
            return meetings.filter { $0.status == .scheduled }
        default:
            return []
        }
    }
}
