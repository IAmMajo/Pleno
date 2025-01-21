import Combine
import Foundation
import MeetingServiceDTOs

class AttendanceManager: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var attendances: [GetAttendanceDTO] = [] // Records-Array

    private let baseURL = "https://kivop.ipv64.net"

    func fetchAttendances(meetingId: UUID) {
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

        // Setze isLoading auf true, um den Start des Ladevorgangs anzuzeigen
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil // Zurücksetzen der Fehlermeldung
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false // Ladevorgang abgeschlossen
            }

            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                }
                print("Network error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self?.errorMessage = "No data received from server"
                }
                print("No data received from server")
                return
            }

            // Debugging: JSON-String anzeigen
            if let jsonString = String(data: data, encoding: .utf8) {
                //print("Server Response: \(jsonString)")
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            do {
                // Dekodieren der JSON-Daten in ein Array von `GetAttendanceDTO`
                let decodedAttendances = try decoder.decode([GetAttendanceDTO].self, from: data)
                DispatchQueue.main.async {
                    self?.attendances = decodedAttendances // Aktualisiere das @Published-Array
                    self?.errorMessage = nil // Erfolgreiches Dekodieren
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = "JSON Decode Error: \(error.localizedDescription)"
                }
                print("JSON Decode Error: \(error.localizedDescription)")
            }
        }.resume()
    }
    // Funktion mit Rückgabewert
    func fetchAttendances2(meetingId: UUID) async throws -> [GetAttendanceDTO] {
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

        // Überprüfen, ob die Antwort gültig ist
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "Server responded with status code: \(httpResponse.statusCode)"])
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            // Dekodieren der JSON-Daten in ein Array von `GetAttendanceDTO`
            let decodedAttendances = try decoder.decode([GetAttendanceDTO].self, from: data)
            return decodedAttendances
        } catch {
            throw URLError(.cannotDecodeContentData, userInfo: [NSLocalizedDescriptionKey: "JSON Decode Error: \(error.localizedDescription)"])
        }
    }
}
extension AttendanceManager {
    /// Gibt die Anzahl der Teilnehmer und die Gesamtzahl der Personen in einem Meeting zurück
    func attendanceSummary() -> String {
        let total = attendances.count
        let presentCount = attendances.filter { $0.status == .present }.count
        return "\(presentCount)/\(total)"
    }
    
    func numberOfParticipants() -> Int {
        return attendances.filter { $0.status == .present }.count
    }
    
    /// Gibt ein Array aller teilnehmenden Personen zurück
    func allParticipants() -> [GetIdentityDTO] {
        return attendances.filter { $0.status == .present }.map { $0.identity }
    }
}
