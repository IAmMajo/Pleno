//
//  AttendanceDetailViewModel.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 25.11.24.
//

import Foundation
import MeetingServiceDTOs

class AttendanceDetailViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
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
                
                // URL für die Anfrage erstellen
                guard let url = URL(string: "\(baseURL)/meetings/\(meeting.id)/attendances") else {
                    throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
                // API-Aufruf starten
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw NSError(domain: "Failed to fetch attendances", code: 500, userInfo: nil)
                }
                
                // JSON dekodieren und auf dem Hauptthread verarbeiten
                let decoder = JSONDecoder()
                DispatchQueue.main.async {
                    do {
                        let fetchedAttendances = try decoder.decode([GetAttendanceDTO].self, from: data)
                        self.attendances = fetchedAttendances
                        
                        // Anzahl der Anwesenheiten in der Konsole ausgeben
                        print("Anzahl der abgerufenen Anwesenheiten: \(fetchedAttendances.count)")
                    } catch {
                        self.errorMessage = "Fehler beim Dekodieren der Anwesenheiten: \(error.localizedDescription)"
                    }
                    self.isLoading = false
                }
            } catch {
                // Fehler auf dem Hauptthread behandeln
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
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
        attendances.filter { $0.status == .absent }.count
    }
}
