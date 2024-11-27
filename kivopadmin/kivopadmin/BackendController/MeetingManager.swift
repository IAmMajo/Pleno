import Combine
import Foundation
import MeetingServiceDTOs

class MeetingManager: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func createMeeting(_ meeting: CreateMeetingDTO) {
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

    
    
    //
    @Published var meetings: [GetMeetingDTO] = [] // Meetings-Array
    @Published var currentMeeting: GetMeetingDTO?  // Meetings-Array
    
    func fetchAllMeetings() {
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

                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    self?.errorMessage = "Invalid server response."
                    return
                }

                guard let data = data else {
                    self?.errorMessage = "No data received."
                    return
                }

                // Debug JSON
                print(String(data: data, encoding: .utf8) ?? "Invalid JSON")

                do {
                    // Transformiere die JSON-Daten
                    let transformedData = try self?.transformJSON(data: data)
                    if let transformedData = transformedData {
                        let fetchedMeetings = try JSONDecoder().decode([GetMeetingDTO].self, from: transformedData)
                        self?.meetings = fetchedMeetings
                        self?.getCurrentMeeting()
                    }
                } catch {
                    self?.errorMessage = "Failed to decode meetings: \(error.localizedDescription)"
                    print("Decoding error: \(error)") // Detaillierte Fehlermeldung
                }
            }
        }.resume()
    }
    
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

    
    func updateMeeting(meetingId: UUID, patchDTO: PatchMeetingDTO, completion: @escaping () -> Void) {
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
        encoder.dateEncodingStrategy = .iso8601 // Datumsformatierung

        do {
            let jsonData = try encoder.encode(patchDTO)
            request.httpBody = jsonData

            // JSON-Daten loggen (optional für Debugging)
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

                if !(200...299).contains(httpResponse.statusCode) {
                    self?.errorMessage = "Server error: \(httpResponse.statusCode) - \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                    if let data = data, let responseText = String(data: data, encoding: .utf8) {
                        print("Server Response: \(responseText)")
                    }
                    return
                }

//                // Erfolgreiches Update: Kein erneutes Abrufen der Daten, nur das lokale Array aktualisieren
//                if let data = data {
//                    do {
//                        let updatedMeeting = try JSONDecoder().decode(GetMeetingDTO.self, from: data)
//                        if let index = self?.meetings.firstIndex(where: { $0.id == meetingId }) {
//                            self?.meetings[index] = updatedMeeting
//                        }
//                        completion()
//                    } catch {
//                        self?.errorMessage = "Failed to decode updated meeting: \(error.localizedDescription)"
//                        print("Decoding error: \(error)") // Debugging
//                    }
//                }
            }
        }.resume()
    }
    // Neue Funktion zum Abrufen eines einzelnen Meetings anhand der ID
    func getSingleMeeting(meetingId: UUID, completion: @escaping (Result<GetMeetingDTO, Error>) -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/\(meetingId.uuidString)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(NSError(domain: "Unauthorized", code: 2, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 3, userInfo: nil)))
                return
            }

            // Debugging-Ausgabe: Zeigt den erhaltenen JSON-String an
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Server Response: \(jsonString)") // Zeigt den Roh-JSON-Text an
            }

            let decoder = JSONDecoder()

            // Konfiguriere benutzerdefinierte Strategien für Datum und UUID
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            do {
                // Versuche, die Antwort in das erwartete Model zu dekodieren
                let meeting = try decoder.decode(GetMeetingDTO.self, from: data)
                completion(.success(meeting))
            } catch {
                completion(.failure(error)) // Fehler beim Dekodieren
                print("JSON Decode Error: \(error.localizedDescription)") // Zeigt den Fehler beim Dekodieren an
            }
        }.resume()
    }
    
    func deleteMeeting(meetingId: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        // Erstellen der URL mit der Meeting-ID
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/\(meetingId.uuidString)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"  // Setze HTTP-Methode auf DELETE
        
        // Füge den Bearer-Token hinzu, wenn vorhanden
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
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                // Erfolgreiches Löschen
                completion(.success(()))
            } else {
                // Fehler beim Löschen
                let error = NSError(domain: "Delete Error", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to delete meeting."])
                completion(.failure(error))
            }
        }.resume()
        
        
    }
    func startMeeting(meetingId: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        // Erstellen der URL mit der Meeting-ID
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/\(meetingId.uuidString)/begin") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"  // Setze HTTP-Methode auf DELETE
        
        // Füge den Bearer-Token hinzu, wenn vorhanden
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
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                // Erfolgreiches Löschen
                completion(.success(()))
            } else {
                // Fehler beim Löschen
                let error = NSError(domain: "Delete Error", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to start meeting."])
                completion(.failure(error))
            }
        }.resume()
        
        
    }

    func endMeeting(meetingId: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        // Erstellen der URL mit der Meeting-ID
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/\(meetingId.uuidString)/end") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"  // Setze HTTP-Methode auf DELETE
        
        // Füge den Bearer-Token hinzu, wenn vorhanden
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
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                // Erfolgreiches Löschen
                completion(.success(()))
            } else {
                // Fehler beim Löschen
                let error = NSError(domain: "Delete Error", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to end meeting."])
                completion(.failure(error))
            }
        }.resume()
        
        
    }


        private func transformJSON(data: Data) throws -> Data {
        // Parse the original JSON into an array of dictionaries
        guard var meetings = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
            throw NSError(domain: "Invalid JSON format", code: 1, userInfo: nil)
        }

        // Transform the "start" field from String to Double (Unix timestamp)
        for i in 0..<meetings.count {
            if let startString = meetings[i]["start"] as? String {
                let formatter = ISO8601DateFormatter()
                if let date = formatter.date(from: startString) {
                    meetings[i]["start"] = date.timeIntervalSince1970 // Transform into Double
                }
            }
        }

        // Convert the modified array back to JSON data
        return try JSONSerialization.data(withJSONObject: meetings, options: [])
    }


}
