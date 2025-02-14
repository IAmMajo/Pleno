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

// ViewModel für Sitzungen
class MeetingManager: ObservableObject {
    // Gibt den Zustand des ViewModels an
    @Published var isLoading: Bool = false
    
    // Potentielle Fehlermeldung
    @Published var errorMessage: String? = nil
    
    // Array mit allen Sitzungen
    @Published var meetings: [GetMeetingDTO] = []
    
    // Aktuelle Sitzung
    @Published var currentMeeting: GetMeetingDTO?
    
    // Ausgewählte Sitzung
    @Published var selectedMeeting: GetMeetingDTO?

    // Erstellt eine Sitzung
    func createMeeting(_ meeting: CreateMeetingDTO) {
        errorMessage = nil
        guard let url = URL(string: "https://kivop.ipv64.net/meetings") else {
            self.errorMessage = "Invalid URL."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Authentifizierung hinzufügen
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            self.errorMessage = "Unauthorized: Token not found."
            return
        }

        // JSON-Daten in den Body der Anfrage schreiben
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 // Sicherstellen, dass das Datum im richtigen Format kodiert wird

        do {
            let jsonData = try encoder.encode(meeting)
            request.httpBody = jsonData

            // JSON-Daten loggen
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("JSON Payload: \(jsonString)")
            }
        } catch {
            self.errorMessage = "Failed to encode meeting data: \(error.localizedDescription)"
            return
        }

        isLoading = true

        // Netzwerkaufruf starten
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage = "Unexpected response format."
                    return
                }

                if !(200...299).contains(httpResponse.statusCode) {
                    self?.errorMessage = "Server error: \(httpResponse.statusCode) - \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                    if let data = data, let responseText = String(data: data, encoding: .utf8) {
                        print("Server Response: \(responseText)")
                    }
                    return
                }

                // Erfolg: Daten verarbeiten
                if let data = data {
                    print("Success: \(String(data: data, encoding: .utf8) ?? "No response data")")
                }

                self?.errorMessage = nil // Erfolgreich
            }
        }.resume()
    }

    // Lädt alle Sitzungen
    func fetchAllMeetings() {
        errorMessage = nil
        guard let url = URL(string: "https://kivop.ipv64.net/meetings") else {
            errorMessage = "Invalid URL."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            errorMessage = "Unauthorized: Token not found."
            return
        }

        isLoading = true

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage = "Invalid response from server."
                    return
                }

                guard let data = data else {
                    self?.errorMessage = "No data received."
                    return
                }

                let decoder = JSONDecoder()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                decoder.dateDecodingStrategy = .formatted(formatter)

                // Prüfen, ob der Server eine Fehlermeldung geschickt hat
                if !(200...299).contains(httpResponse.statusCode) {
                    do {
                        let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
                        self?.errorMessage = errorResponse.reason
                        print("Server error: \(errorResponse.reason)")
                    } catch {
                        self?.errorMessage = "Server error: \(httpResponse.statusCode)"
                        print("Failed to decode error response")
                    }
                    return
                }

                // Erfolgreiches Dekodieren der Meetings
                do {
                    self?.meetings = try decoder.decode([GetMeetingDTO].self, from: data)
                    self?.getCurrentMeeting()
                    self?.errorMessage = nil // Falls vorher ein Fehler gesetzt war, wird er zurückgesetzt
                } catch {
                    self?.errorMessage = "Failed to decode meetings: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }

    // Gibt alle Sitzungen zurück, die aktuell laufen
    func getCurrentMeeting() {
        // Überprüfen, ob es Meetings gibt
        guard !meetings.isEmpty else {
            currentMeeting = nil // Keine Meetings vorhanden
            return
        }
        
        // Suche nach einem Meeting mit dem Status "inSession"
        if let meetingInSession = meetings.first(where: { $0.status == .inSession }) {
            currentMeeting = meetingInSession // Aktuelles Meeting gefunden
        } else {
            currentMeeting = nil // Kein Meeting mit "inSession"-Status gefunden
        }
    }

    // Aktualisiert eine Sitzung
    func updateMeeting(meetingId: UUID, patchDTO: PatchMeetingDTO, completion: @escaping () -> Void) {
        errorMessage = nil
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/\(meetingId.uuidString)") else {
            self.errorMessage = "Invalid URL."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Authentifizierung hinzufügen
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            self.errorMessage = "Unauthorized: Token not found."
            return
        }

        // JSON-Daten in den Body der Anfrage schreiben
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        do {
            let jsonData = try encoder.encode(patchDTO)
            request.httpBody = jsonData

            // Debugging: JSON-Payload anzeigen
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("JSON Payload for PATCH: \(jsonString)")
            }
        } catch {
            self.errorMessage = "Failed to encode meeting data: \(error.localizedDescription)"
            return
        }

        isLoading = true

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage = "Unexpected response format."
                    return
                }

                guard let data = data else {
                    self?.errorMessage = "No response data from server."
                    return
                }

                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                // Falls der Server eine Fehlermeldung schickt, diese auslesen
                if !(200...299).contains(httpResponse.statusCode) {
                    do {
                        let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
                        self?.errorMessage = errorResponse.reason
                        print("Server error: \(errorResponse.reason)")
                    } catch {
                        self?.errorMessage = "Server error: \(httpResponse.statusCode) - \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                        print("Failed to decode error response")
                    }
                    return
                }

                // Falls die Anfrage erfolgreich war, completion-Handler aufrufen
                self?.errorMessage = nil // Falls vorher ein Fehler war, wird er zurückgesetzt
                completion()
            }
        }.resume()
    }
    
    // Lädt eine einzelne Sitzung
    func getSingleMeeting(meetingId: UUID) {
        errorMessage = nil
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/\(meetingId)") else {
            errorMessage = "Invalid URL."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            errorMessage = "Unauthorized: Token not found."
            return
        }

        isLoading = true

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage = "Invalid response from server."
                    return
                }

                guard let data = data else {
                    self?.errorMessage = "No data received."
                    return
                }

                let decoder = JSONDecoder()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                decoder.dateDecodingStrategy = .formatted(formatter)

                // Prüfen, ob der Server eine Fehlermeldung geschickt hat
                if !(200...299).contains(httpResponse.statusCode) {
                    do {
                        let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
                        self?.errorMessage = errorResponse.reason
                        print("Server error: \(errorResponse.reason)")
                    } catch {
                        self?.errorMessage = "Server error: \(httpResponse.statusCode)"
                        print("Failed to decode error response")
                    }
                    return
                }

                // Erfolgreiches Dekodieren der Meetings
                do {
                    self?.selectedMeeting = try decoder.decode(GetMeetingDTO.self, from: data)
                    self?.errorMessage = nil // Falls vorher ein Fehler gesetzt war, wird er zurückgesetzt
                } catch {
                    self?.errorMessage = "Failed to decode meetings: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }

    // Löscht eine Sitzung
    func deleteMeeting(meetingId: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        errorMessage = nil
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/\(meetingId.uuidString)") else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "Invalid URL", code: 1, userInfo: nil)))
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        // Authentifizierung hinzufügen
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "Unauthorized", code: 2, userInfo: nil)))
            }
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {  // 🔹 Stellt sicher, dass UI-Updates sicher sind!
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NSError(domain: "Invalid response format", code: 3, userInfo: nil)))
                    return
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    if let data = data {
                        do {
                            let decoder = JSONDecoder()
                            let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
                            completion(.failure(NSError(domain: "Server error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.reason])))
                            print("Server error: \(errorResponse.reason)")
                        } catch {
                            completion(.failure(NSError(domain: "Server error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected server error"])))
                            if let jsonString = String(data: data, encoding: .utf8) {
                                print("Failed to decode error response. Server Response: \(jsonString)")
                            }
                        }
                    } else {
                        completion(.failure(NSError(domain: "Server error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "No error message received."])))
                    }
                    return
                }

                completion(.success(()))
            }
        }.resume()
    }

    // Startet eine Sitzung
    func startMeeting(meetingId: UUID, completion: @escaping (Result<Data, Error>) -> Void) {
        errorMessage = nil
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/\(meetingId.uuidString)/begin") else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "Invalid URL", code: 1, userInfo: nil)))
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        // Füge den Bearer-Token hinzu
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "Unauthorized", code: 2, userInfo: nil)))
            }
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NSError(domain: "Invalid response format", code: 3, userInfo: nil)))
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    if let data = data {
                        do {
                            let decoder = JSONDecoder()
                            let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
                            let error = NSError(
                                domain: "Server error",
                                code: httpResponse.statusCode,
                                userInfo: [NSLocalizedDescriptionKey: errorResponse.reason]
                            )
                            completion(.failure(error))
                            print("Server error: \(errorResponse.reason)")
                        } catch {
                            completion(.failure(NSError(domain: "Server error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected server error"])))
                            if let jsonString = String(data: data, encoding: .utf8) {
                                print("Failed to decode error response. Server Response: \(jsonString)")
                            }
                        }
                    } else {
                        completion(.failure(NSError(domain: "Server error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "No error message received."])))
                    }
                    return
                }
                
                // Erfolgreiche Antwort mit Daten oder leerem Body
                completion(.success(data ?? Data()))
            }
        }.resume()
    }

    // Beendet eine Sitzung
    func endMeeting(meetingId: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        errorMessage = nil
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/\(meetingId.uuidString)/end") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"  // Setze HTTP-Methode auf PUT

        // Füge den Bearer-Token hinzu
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(NSError(domain: "Unauthorized", code: 2, userInfo: nil)))
            return
        }

        // Sende die Anfrage
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Fehlerbehandlung
            if let error = error {
                completion(.failure(error))
                return
            }

            // Überprüfe den Statuscode der Antwort
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    if let data = data {
                        do {
                            // Versuche, die Fehlernachricht vom Backend zu dekodieren
                            let decoder = JSONDecoder()
                            let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
                            // Erstelle eine Fehlernachricht aus der Antwort des Servers
                            let error = NSError(
                                domain: "Server Error",
                                code: httpResponse.statusCode,
                                userInfo: [NSLocalizedDescriptionKey: errorResponse.reason]
                            )
                            completion(.failure(error))
                            print("Server error: \(errorResponse.reason)")  // Zum Debuggen
                        } catch {
                            // Fehler beim Dekodieren der Antwort
                            completion(.failure(NSError(domain: "Server Error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected server error"])))
                            if let jsonString = String(data: data, encoding: .utf8) {
                                print("Failed to decode error response. Server Response: \(jsonString)")  // Zeigt den Raw-JSON-Text an
                            }
                        }
                    } else {
                        // Kein Fehlertext im Body, aber ein HTTP-Fehler
                        let error = NSError(domain: "Server Error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "No error message received."])
                        completion(.failure(error))
                    }
                    return
                }
                
                // Erfolgreiches Ende des Meetings
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "Invalid response format", code: 3, userInfo: nil)))
            }
        }.resume()
    }


}
