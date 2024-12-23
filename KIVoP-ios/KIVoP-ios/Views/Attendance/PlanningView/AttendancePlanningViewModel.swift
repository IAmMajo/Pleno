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
    @Published var errorMessage: String? = nil
    @Published var attendances: [GetAttendanceDTO] = []
    @Published var isLoading: Bool = true
    
    private let baseURL = "https://kivop.ipv64.net"
    var meeting: GetMeetingDTO
    
    init(meeting: GetMeetingDTO) {
        self.meeting = meeting
    }
    
    public func fetchAttendances() {
        isLoading = true
        Task {
            do {
                // URL und Request erstellen
                guard let url = URL(string: "\(baseURL)/meetings/\(meeting.id)/attendances") else {
                    print("Ungültige URL.")
                    isLoading = false
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                if let token = UserDefaults.standard.string(forKey: "jwtToken") {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                } else {
                    errorMessage = "Unauthorized: Token not found."
                    isLoading = false
                    return
                }
                
                // API-Aufruf und Antwort verarbeiten
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Fehlerhafte Antwort vom Server.")
                    isLoading = false
                    return
                }
                
                // JSON dekodieren
                self.attendances = try JSONDecoder().decode([GetAttendanceDTO].self, from: data)
                
            } catch {
                print("Fehler: \(error.localizedDescription)")
            }
            
            isLoading = false
        }
    }
    
    public func markAttendanceAsAccepted() {
        isLoading = true
        Task {
            do {
                // URL für die Anfrage erstellen
                guard let url = URL(string: "\(baseURL)/meetings/\(meeting.id)/plan-attendance/present") else {
                    isLoading = false
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "PUT"
                if let token = UserDefaults.standard.string(forKey: "jwtToken") {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                } else {
                    isLoading = false
                    return
                }
                
                // API-Aufruf starten
                let (_, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
                    isLoading = false
                    return
                }
                fetchAttendances()
            }
        }
    }

    public func markAttendanceAsAbsent() {
        isLoading = true
        Task {
            do {
                // URL für die Anfrage erstellen
                guard let url = URL(string: "\(baseURL)/meetings/\(meeting.id)/plan-attendance/absent") else {
                    isLoading = false
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "PUT"
                if let token = UserDefaults.standard.string(forKey: "jwtToken") {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                } else {
                    isLoading = false
                    return
                }
                
                // API-Aufruf starten
                let (_, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
                    isLoading = false
                    return
                }
                fetchAttendances()
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
}
