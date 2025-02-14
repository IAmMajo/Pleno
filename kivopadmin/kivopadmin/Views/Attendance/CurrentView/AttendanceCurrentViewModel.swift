// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
        statusMessage = nil  // Vor jedem Versuch die Nachricht zurücksetzen
        Task {
            do {
                // URL und Request vorbereiten
                guard let url = URL(string: "\(baseURL)/meetings/\(meeting.id)/attend/\(participationCode)") else {
                    print("Ungültige URL.")
                    isLoading = false
                    statusMessage = "Beim betreten der Sitzung ist ein Fehler aufgetreten. Bitte versuchen Sie es erneut."
                    return
                }

                var request = URLRequest(url: url)
                request.httpMethod = "PUT"
                if let token = UserDefaults.standard.string(forKey: "jwtToken") {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                } else {
                    errorMessage = "Unauthorized: Token not found."
                    isLoading = false
                    statusMessage = "Beim betreten der Sitzung ist ein Fehler aufgetreten. Bitte versuchen Sie es erneut."
                    return
                }

                // API-Aufruf und Antwort verarbeiten
                let (_, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Ungültige Antwort vom Server.")
                    isLoading = false
                    statusMessage = "Beim betreten der Sitzung ist ein Fehler aufgetreten. Bitte versuchen Sie es erneut."
                    return
                }

                if httpResponse.statusCode == 204 {
                    print("Erfolgreich am Meeting teilgenommen!")
                    statusMessage = "Erfolgreich der Sitzung beigetreten."
                    fetchAttendances() // Attendances nach erfolgreichem Beitritt neu laden
                } else {
                    print("Fehler: \(httpResponse.statusCode) beim Beitritt zum Meeting.")
                    statusMessage = "Beim betreten der Sitzung ist ein Fehler aufgetreten. Bitte versuchen Sie es erneut."
                }
            } catch {
                print("Fehler: \(error.localizedDescription)")
                statusMessage = "Beim betreten der Sitzung ist ein Fehler aufgetreten. Bitte versuchen Sie es erneut."
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
