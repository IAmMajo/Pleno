//
//  AttendancePlanningViewModel.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 25.11.24.
//

import Foundation
import MeetingServiceDTOs

@MainActor
class AttendancePlanningViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var attendances: [GetAttendanceDTO] = []
    
    private let baseURL = "https://kivop.ipv64.net"
    var meeting: GetMeetingDTO
    
    init(meeting: GetMeetingDTO) {
        self.meeting = meeting
        fetchAttendances()
    }
    
    public func fetchAttendances() {
        Task {
            do {
                // Authentifizierung und Token holen
                let token = try await AuthController.shared.getAuthToken()
                
                // URL und Request erstellen
                guard let url = URL(string: "\(baseURL)/meetings/\(meeting.id)/attendances") else {
                    print("Ungültige URL.")
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
                // API-Aufruf und Antwort verarbeiten
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Fehlerhafte Antwort vom Server.")
                    return
                }
                
                // JSON dekodieren
                let fetchedAttendances = try JSONDecoder().decode([GetAttendanceDTO].self, from: data)
                
                // Attendances sortieren
                self.attendances = fetchedAttendances.sorted {
                    let orderA = self.sortOrder(for: $0.status)
                    let orderB = self.sortOrder(for: $1.status)
                    
                    // Zuerst nach Status, dann alphabetisch nach Name sortieren
                    return orderA == orderB
                        ? $0.identity.name.localizedCaseInsensitiveCompare($1.identity.name) == .orderedAscending
                        : orderA < orderB
                }
                
            } catch {
                print("Fehler: \(error.localizedDescription)")
            }
        }
    }
    
    public func markAttendanceAsAccepted() {
        Task {
            do {
                // Authentifizierung und Token holen
                let token = try await AuthController.shared.getAuthToken()
                
                // URL für die Anfrage erstellen
                guard let url = URL(string: "\(baseURL)/meetings/\(meeting.id)/plan-attendance/present") else {
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "PUT"
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
                // API-Aufruf starten
                let (_, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
                    return
                }
                fetchAttendances()
            }
        }
    }

    public func markAttendanceAsAbsent() {
        Task {
            do {
                // Authentifizierung und Token holen
                let token = try await AuthController.shared.getAuthToken()
                
                // URL für die Anfrage erstellen
                guard let url = URL(string: "\(baseURL)/meetings/\(meeting.id)/plan-attendance/absent") else {
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "PUT"
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
                // API-Aufruf starten
                let (_, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
                    return
                }
                fetchAttendances()
            }
        }
    }

    var filteredAttendances: [GetAttendanceDTO] {
        let filtered = searchText.isEmpty ? attendances : attendances.filter {
            $0.identity.id.uuidString.contains(searchText) ||
            $0.identity.name.localizedCaseInsensitiveContains(searchText)
        }
        
        // Anwenden der Sortierlogik
        return filtered.sorted {
            // Vergleiche zuerst den Status
            if sortOrder(for: $0.status) == sortOrder(for: $1.status) {
                // Wenn der Status gleich ist, sortiere alphabetisch nach dem Namen
                return $0.identity.name.localizedCaseInsensitiveCompare($1.identity.name) == .orderedAscending
            } else {
                // Vergleiche den Status basierend auf der Reihenfolge
                return sortOrder(for: $0.status) < sortOrder(for: $1.status)
            }
        }
    }
    
    var nilCount: Int {
        attendances.filter { $0.status == nil }.count
    }
    
    var acceptedCount: Int {
        attendances.filter { $0.status == .accepted }.count
    }
    
    var absentCount: Int {
        attendances.filter { $0.status == .absent }.count
    }
    
    // Sortierungspriorität definieren
    private func sortOrder(for status: AttendanceStatus?) -> Int {
        switch status {
        case .accepted:
            return 0
        case .none:
            return 1
        case .absent:
            return 2
        case .some(.present):
            return 3
        }
    }
}
