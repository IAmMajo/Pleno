//
//  AttendanceViewModel.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 25.11.24.
//

import Foundation
import SwiftUI
import MeetingServiceDTOs
// Just for testing
import AuthServiceDTOs

class AttendanceViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedTab: Int = 0
    @Published var token: String
    @Published var errorMessage: String?
    @Published var meetings: [GetMeetingDTO] = exampleMeetings
    
    // Initialisieren des ViewModels mit dem gespeicherten Token aus UserDefaults
    init() {
        // Laden des Tokens aus UserDefaults
        if let savedToken = UserDefaults.standard.string(forKey: "authToken") {
            self.token = savedToken
        } else {
            self.token = ""  // Leerer Token, wenn keiner gespeichert ist
        }
        // Meetings laden
        loadMeetingsFromAPI()
    }

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
        Task {
            do {
                // Token prüfen oder Login durchführen
                let token: String
                if let storedToken = UserDefaults.standard.string(forKey: "authToken"), !storedToken.isEmpty {
                    token = storedToken
                } else {
                    // Token nicht gefunden, also Login durchführen
                    token = try await loginUser()  // Hier wird await verwendet
                    // Token im UserDefaults speichern
                    UserDefaults.standard.set(token, forKey: "authToken")
                }
                
                // Meetings abrufen
                try await fetchMeetings(token: token)
            } catch {
                // Fehlerbehandlung auf dem Hauptthread
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // Login und Token zurückgeben
    func loginUser() async throws -> String {
        let loginData = UserLoginDTO(
            email: "henrik.peltzer@gmail.com",  // Beispiel-E-Mail
            password: "Test123"  // Beispiel-Passwort
        )
        
        guard let url = URL(string: "https://kivop.ipv64.net/auth/login") else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(loginData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "Login failed", code: 401, userInfo: nil)
        }
        
        guard let tokenResponse = try? JSONDecoder().decode(TokenResponseDTO.self, from: data),
              let token = tokenResponse.token else {
            throw NSError(domain: "Token parsing failed", code: 500, userInfo: nil)
        }
        
        // Token in UserDefaults speichern
        UserDefaults.standard.set(token, forKey: "authToken")
        print("Token erhalten und gespeichert: \(token)")
        return token
    }

    
    // Meetings mit dem Token abrufen
    func fetchMeetings(token: String) async throws {
        guard let url = URL(string: "https://kivop.ipv64.net/meetings") else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("Token lautet: \(token)")
        
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
                    
                    // Anzahl der Meetings in der Konsole ausgeben
                    print("Anzahl der abgerufenen Meetings: \(fetchedMeetings.count)")
                } catch {
                    // Fehlerbehandlung beim Dekodieren der Meetings
                    self.errorMessage = "Fehler beim Dekodieren der Meetings: \(error.localizedDescription)"
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
