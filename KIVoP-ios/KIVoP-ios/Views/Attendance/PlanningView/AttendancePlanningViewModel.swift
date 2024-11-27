//
//  AttendancePlanningViewModel.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 25.11.24.
//

import Foundation
import MeetingServiceDTOs

class AttendancePlanningViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var attendances: [GetAttendanceDTO] = []
    
    private let baseURL = "https://kivop.ipv64.net"
    var meeting: GetMeetingDTO
    
    init(meeting: GetMeetingDTO) {
        self.meeting = meeting
        fetchAttendances()
    }
    
    private func fetchAttendances() {
        Task {
            do {
                // Authentifizierung und Token holen
                let token = try await AuthController.shared.getAuthToken()
                
                // URL und Request erstellen
                guard let url = URL(string: "\(baseURL)/meetings/\(meeting.id)/attendances") else {
                    return
                }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

                // API-Aufruf und Antwort verarbeiten
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    return
                }

                // JSON dekodieren
                let fetchedAttendances = try JSONDecoder().decode([GetAttendanceDTO].self, from: data)

                self.attendances = fetchedAttendances.sorted {
                    self.sortOrder(for: $0.status) == self.sortOrder(for: $1.status)
                        ? $0.identity.name.localizedCaseInsensitiveCompare($1.identity.name) == .orderedAscending
                        : self.sortOrder(for: $0.status) < self.sortOrder(for: $1.status)
                }
            } catch {
                print("Fehler: \(error.localizedDescription)")
            }
        }
    }
    
    public func markAttendanceAsPresent() {
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
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    return
                }
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
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    return
                }
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
    
    var presentCount: Int {
        attendances.filter { $0.status == .present }.count
    }
    
    var acceptedCount: Int {
        attendances.filter { $0.status == .accepted }.count
    }
    
    var absentCount: Int {
        attendances.filter { $0.status == .absent }.count
    }
    
    private func sortOrder(for status: AttendanceStatus) -> Int {
        switch status {
        case .present:
            return 0 // Höchste Priorität
        case .accepted:
            return 1 // Zweithöchste Priorität
        case .absent:
            return 2 // Niedrigste Priorität
        }
    }
}
