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



import Combine
import Foundation
import MeetingServiceDTOs


// ViewModel für Anwesenheiten
class AttendanceManager: ObservableObject {
    // Gibt den Zustand des ViewModels an
    @Published var isLoading: Bool = false
    
    // Variable für Potentielle Fehlermeldungen
    @Published var errorMessage: String? = nil
    
    // Array mit allen Teilnehmern einer Sitzung
    @Published var attendances: [GetAttendanceDTO] = [] // Records-Array

    private let baseURL = "https://kivop.ipv64.net"

    // Lädt Anwesenheiten für eine Sitzung
    func fetchAttendances(meetingId: UUID) {
        errorMessage = nil
        guard let url = URL(string: "\(baseURL)/meetings/\(meetingId.uuidString)/attendances") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
            }
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "Unauthorized: No token found"
            }
            print("Unauthorized: No token found")
            return
        }

        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                }
                print("Network error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self?.errorMessage = "Invalid response from server"
                }
                print("Invalid response from server")
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self?.errorMessage = "No data received from server"
                }
                print("No data received from server")
                return
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            // Wenn der HTTP-Status nicht 2xx ist, versuche, eine Fehlermeldung aus dem JSON zu lesen
            if !(200...299).contains(httpResponse.statusCode) {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
                    DispatchQueue.main.async {
                        self?.errorMessage = errorResponse.reason
                    }
                    print("Server error: \(errorResponse.reason)")
                } catch {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Server error: \(httpResponse.statusCode)"
                    }
                    print("Server error with status code: \(httpResponse.statusCode)")
                }
                return
            }

            // Erfolgreiches Dekodieren der Attendance-Daten
            do {
                let decodedAttendances = try decoder.decode([GetAttendanceDTO].self, from: data)
                DispatchQueue.main.async {
                    self?.attendances = decodedAttendances
                    self?.errorMessage = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = "JSON Decode Error: \(error.localizedDescription)"
                }
                print("JSON Decode Error: \(error.localizedDescription)")
            }
        }.resume()
    }

    // Lädt Anwesenheiten für eine Sitzung
    // Funktion mit Rückgabewert
    func fetchAttendances2(meetingId: UUID) async throws -> [GetAttendanceDTO] {
        errorMessage = nil
        guard let url = URL(string: "\(baseURL)/meetings/\(meetingId.uuidString)/attendances") else {
            throw URLError(.badURL, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            throw URLError(.userAuthenticationRequired, userInfo: [NSLocalizedDescriptionKey: "Unauthorized: No token found"])
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        // Überprüfen, ob der Server eine Fehlermeldung gesendet hat (Statuscode nicht 2xx)
        if !(200...299).contains(httpResponse.statusCode) {
            do {
                let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
                throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: errorResponse.reason])
            } catch {
                throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "Server error: \(httpResponse.statusCode)"])
            }
        }

        // Falls keine Fehler, versuche die Attendance-Daten zu dekodieren
        do {
            return try decoder.decode([GetAttendanceDTO].self, from: data)
        } catch {
            throw URLError(.cannotDecodeContentData, userInfo: [NSLocalizedDescriptionKey: "JSON Decode Error: \(error.localizedDescription)"])
        }
    }

}
extension AttendanceManager {
    // Gibt die Anzahl der Teilnehmer und die Gesamtzahl der Personen in einem Meeting zurück
    func attendanceSummary() -> String {
        let total = attendances.count
        let presentCount = attendances.filter { $0.status == .present }.count
        return "\(presentCount)/\(total)"
    }
    
    // Gibt die Anzahl der Teilnehmer wieder
    func numberOfParticipants() -> Int {
        return attendances.filter { $0.status == .present }.count
    }
    
    // Gibt ein Array aller teilnehmenden Personen zurück
    func allParticipants() -> [GetIdentityDTO] {
        return attendances.filter { $0.status == .present }.map { $0.identity }
    }
}
