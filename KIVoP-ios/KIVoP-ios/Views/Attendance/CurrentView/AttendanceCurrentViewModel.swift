//
//  AttendanceCurrentViewModel.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 25.11.24.
//

import SwiftUI
import MeetingServiceDTOs
@MainActor
class AttendanceCurrentViewModel: ObservableObject {
    @Published var statusMessage: String?
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    @Published var participationCode: String = ""
    @Published var attendances: [GetAttendanceDTO] = []
    @Published var isLoading: Bool = true
    
    private let baseURL = "https://kivop.ipv64.net"
    var meeting: GetMeetingDTO
    
    init(meeting: GetMeetingDTO) {
        self.meeting = meeting
    }
    
    func fetchAttendances() {
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
    
    func joinMeeting() {
        isLoading = true
        Task {
            do {
                // URL und Request vorbereiten
                guard let url = URL(string: "\(baseURL)/meetings/\(meeting.id)/attend/\(participationCode)") else {
                    print("Ungültige URL.")
                    isLoading = false  // Ladezustand deaktivieren
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "PUT"
                if let token = UserDefaults.standard.string(forKey: "jwtToken") {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                } else {
                    errorMessage = "Unauthorized: Token not found."
                    isLoading = false  // Ladezustand deaktivieren
                    return
                }
                
                // API-Aufruf und Antwort verarbeiten
                let (_, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Ungültige Antwort vom Server.")
                    isLoading = false
                    return
                }
                
                if httpResponse.statusCode == 204 {
                    print("Erfolgreich am Meeting teilgenommen!")
                    fetchAttendances()
                } else {
                    print("Fehler: \(httpResponse.statusCode) beim Beitritt zum Meeting.")
                }
            } catch {
                print("Fehler: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
    
    // Statuszählung
    var presentCount: Int {
        attendances.filter { $0.status == .present }.count
    }
    
    var acceptedCount: Int {
        attendances.filter { $0.status == .accepted }.count
    }
}
