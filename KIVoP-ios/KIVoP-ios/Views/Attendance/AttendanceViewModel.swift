//
//  AttendanceViewModel.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 25.11.24.
//

import Foundation
import SwiftUI
import MeetingServiceDTOs

@MainActor
class AttendanceViewModel: ObservableObject {

    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    @Published var selectedTab: Int = 0
    @Published var meetings: [GetMeetingDTO] = []
    @Published var isLoading: Bool = false
    
    init() {
        // Konfigurieren der Navbar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.black
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    // Abruf der Meetings von der API
    func fetchMeetings() {
        Task {
            do {
                // Setze isLoading auf true, wenn der Ladevorgang startet
                self.isLoading = true
                self.meetings.removeAll() // sicherstellen, das das Array leer ist bevor es gefüllt wird
                
                guard let url = URL(string: "https://kivop.ipv64.net/meetings") else {
                    throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                if let token = UserDefaults.standard.string(forKey: "jwtToken") {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                } else {
                    errorMessage = "Unauthorized: Token not found."
                    self.isLoading = false
                    return
                }
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw NSError(domain: "Failed to fetch meetings", code: 500, userInfo: nil)
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    DispatchQueue.main.async {
                        do {
                            let fetchedMeetings = try decoder.decode([GetMeetingDTO].self, from: data)
                            self.meetings = fetchedMeetings
                            self.isLoading = false
                        } catch {
                            print("Fehler beim Dekodieren der Meetings: \(error.localizedDescription)")
                            self.isLoading = false
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("\(error.localizedDescription)")
                    self.isLoading = false
                }
            }
        }
    }
    
    // Aktuelle Sitzung (falls vorhanden)
    var currentMeetings: [GetMeetingDTO] {
        meetings
            .filter { $0.status == .inSession }
            .sorted { $0.start < $1.start }
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
    
    // Wechsel zwischen den destinations je nach meeting Status
    func destinationView(for meeting: GetMeetingDTO) -> some View {
        switch meeting.status {
        case .inSession:
            let viewModel = AttendanceCurrentViewModel(meeting: meeting)
            return AnyView(AttendanceCurrentView(viewModel: viewModel))
        case .completed:
            let viewModel = AttendanceDetailViewModel(meeting: meeting)
            return AnyView(AttendanceDetailView(viewModel: viewModel))
        case .scheduled:
            let viewModel = AttendancePlanningViewModel(meeting: meeting)
            return AnyView(AttendancePlanningView(viewModel: viewModel))
        }
    }
}
