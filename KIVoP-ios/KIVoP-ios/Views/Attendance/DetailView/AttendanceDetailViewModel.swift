//
//  AttendanceDetailViewModel.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 25.11.24.
//

import Foundation
import MeetingServiceDTOs

@MainActor
class AttendanceDetailViewModel: ObservableObject {
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
    
    var filteredAttendances: [GetAttendanceDTO] {
        if searchText.isEmpty {
            return attendances
        } else {
            return attendances.filter { $0.identity.id.uuidString.contains(searchText) }
        }
    }
    
    var presentCount: Int {
        attendances.filter { $0.status == .present }.count
    }
    
    var absentCount: Int {
        attendances.filter { $0.status != .present }.count
    }
    
    // Sortierungspriorität definieren
    private func sortOrder(for status: AttendanceStatus?) -> Int {
        switch status {
        case .present:
            return 0
        default:
            return 1
        }
    }
}
