// This file is licensed under the MIT-0 License.

import Combine
import Foundation
import MeetingServiceDTOs

// Neue Struktur für Meetings mit zugehörigen Records
struct MeetingWithRecords {
    var meeting: GetMeetingDTO
    var records: [GetRecordDTO]
}

// ViewModel für die Protokolle
class RecordManager: ObservableObject {
    // Gibt den Zustand des ViewModels an
    @Published var isLoading: Bool = false
    
    // Potentielle Fehlermeldung
    @Published var errorMessage: String? = nil

    // Array mit allen Sitzungen und zugehörigen Protokollen
    @Published var meetingsWithRecords: [MeetingWithRecords] = []
    
    // Anzahl der Protokolle, die noch nicht veröffentlicht wurden
    @Published var recordsNotApproved: Int = 0
    @Published var recordsNotSubmitted: Int = 0
    @Published var recordsApproved: Int = 0
    @Published var record: GetRecordDTO? // Speichern eines einzelnen Records
    @Published var records: [GetRecordDTO] = [] // Records-Array

    // Funktion, die alle Sitzungen mit zugehörigen Protokollen lädt
    func getAllMeetingsWithRecords() {
        errorMessage = nil
        
        var meetings: [GetMeetingDTO] = [] // Meetings-Array

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
                do {
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
                    //print(String(data: data, encoding: .utf8) ?? "Invalid JSON")
                    
                    let decoder = JSONDecoder()
                    
                    // Falls du mit Date-Formaten arbeitest, musst du das Datumsformat konfigurieren:
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    decoder.dateDecodingStrategy = .formatted(formatter)
                    
                    // Dekodiere die Daten
                    meetings = try decoder.decode([GetMeetingDTO].self, from: data)
                    
                    let filteredMeetings = meetings.filter { meeting in
                        return meeting.status == .inSession || meeting.status == .completed
                    }
                    
                    // Schleife durch jedes Meeting und rufe getRecordsMeeting auf
                    var meetingsWithRecords: [MeetingWithRecords] = []
                    let dispatchGroup = DispatchGroup() // Verwende DispatchGroup, um auf alle asynchronen Aufrufe zu warten
                   
                    for meeting in filteredMeetings {
                        dispatchGroup.enter() // Betritt die Gruppe für jede Meeting-Abfrage

                        // Korrigierter Aufruf der Funktion getRecordsMeeting mit Completion-Handler
                        self?.getRecordsMeeting2(meetingId: meeting.id, completion: { records in
                            meetingsWithRecords.append(MeetingWithRecords(meeting: meeting, records: records))
                            dispatchGroup.leave() // Verlässt die Gruppe nach dem Abrufen der Records
                                                    })
                    }
                    
                    // Warten auf alle asynchronen Aufrufe
                    dispatchGroup.notify(queue: .main) {
                        self?.meetingsWithRecords = meetingsWithRecords
                        let notSubmittedRecordsCount = meetingsWithRecords.flatMap { $0.records }
                            .filter { $0.status == .underway } // Filtere nach 'underway' Status
                            .count
                        let submittedRecordsCount = meetingsWithRecords.flatMap { $0.records }
                            .filter { $0.status == .submitted } // Filtere nach 'submitted' Status
                            .count
                        
                        let approvedRecordsCount = meetingsWithRecords.flatMap { $0.records }
                            .filter { $0.status == .approved } // Filtere nach 'submitted' Status
                            .count

                        self?.recordsNotApproved = submittedRecordsCount
                        self?.recordsNotSubmitted = notSubmittedRecordsCount
                        self?.recordsApproved = approvedRecordsCount
                    }
                    
                    
                    

                } catch {
                    self?.errorMessage = "Failed to decode meetings: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }

    // getRecordsMeeting2 muss den Completion-Handler verwenden
    // Diese Funktion wird für die Fuktion getAllMeetingsWithRecords() benötigt
    func getRecordsMeeting2(meetingId: UUID, completion: @escaping ([GetRecordDTO]) -> Void) {
        errorMessage = nil
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/\(meetingId.uuidString)/records") else {
            print("Invalid URL")
            completion([]) // Rückgabe eines leeren Arrays im Fehlerfall
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Unauthorized: No token found")
            completion([]) // Rückgabe eines leeren Arrays im Fehlerfall
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion([]) // Rückgabe eines leeren Arrays im Fehlerfall
                return
            }
            
            guard let data = data else {
                print("No data received from server")
                completion([]) // Rückgabe eines leeren Arrays im Fehlerfall
                return
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            do {
                // Dekodieren der JSON-Daten in ein Array von `GetRecordDTO`
                let decodedRecords = try decoder.decode([GetRecordDTO].self, from: data)
                completion(decodedRecords) // Erfolgreiche Rückgabe der Records
            } catch {
                print("JSON Decode Error: \(error.localizedDescription)")
                completion([]) // Rückgabe eines leeren Arrays im Fehlerfall
            }
        }.resume()
    }
    
    // Lädt Protokolle zu einer Sitzung
    func getRecordsMeeting(meetingId: UUID) {
        errorMessage = nil
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/\(meetingId.uuidString)/records") else {
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
                print("Server Response: \(jsonString)")
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                // Dekodieren der JSON-Daten in ein Array von `GetRecordDTO`
                let decodedRecords = try decoder.decode([GetRecordDTO].self, from: data)
                DispatchQueue.main.async {
                    self?.records = decodedRecords // Aktualisiere das @Published-Array
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
    


    // Lädt ein spezifisches Protokoll
    func getRecordMeetingLang(meetingId: UUID, lang: String) async {
        errorMessage = nil
        // Erstelle die URL für die Anfrage
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/\(meetingId.uuidString)/records/\(lang)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Füge das Token hinzu, falls vorhanden
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Unauthorized: No token found")
            return
        }

        // Sende die Anfrage und verarbeite die Antwort
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received from server")
                return
            }

            // Debugging: Serverantwort in Klartext ausgeben
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Server Response: \(jsonString)")
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            do {
                // Dekodiere das einzelne Record-Objekt
                let decodedRecord = try decoder.decode(GetRecordDTO.self, from: data)
                DispatchQueue.main.async {
                    self?.record = decodedRecord // Das Record speichern
                }
            } catch {
                print("JSON Decode Error: \(error.localizedDescription)")
            }
        }.resume()
    }

    // Aktualisiert ein Protokoll
    func patchRecordMeetingLang(patchRecordDTO: PatchRecordDTO, meetingId: UUID, lang: String) async {
        errorMessage = nil
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/\(meetingId.uuidString)/records/\(lang)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Unauthorized: No token found")
            return
        }

        do {
            // JSON-Body serialisieren
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let bodyData = try encoder.encode(patchRecordDTO)
            
            // Debugging: JSON-Body anzeigen
            if let jsonString = String(data: bodyData, encoding: .utf8) {
                print("Encoded JSON Body: \(jsonString)")
            }

            request.httpBody = bodyData

            // Netzwerk-Request ausführen
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("Record successfully patched.")
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let updatedRecord = try decoder.decode(GetRecordDTO.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.record = updatedRecord // Aktualisiere das @Published-Objekt
                    }
                } else {
                    print("Server Error: \(httpResponse.statusCode)")
                    if let responseBody = String(data: data, encoding: .utf8) {
                        print("Server Response Body: \(responseBody)")
                    }
                }
            }
        } catch {
            print("Error during PATCH request: \(error.localizedDescription)")
        }
    }
    
    // Löscht ein Protokoll
    func deleteRecordMeetingLang(meetingId: UUID, lang: String, completion: @escaping (Result<Void, Error>) -> Void) {
        errorMessage = nil
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/\(meetingId.uuidString)/records/\(lang)") else {
            print("Invalid URL")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Unauthorized: No token found")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unauthorized: No token found"])))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error)) // Netzwerkfehler
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    completion(.success(())) // Erfolg
                } else {
                    let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unbekannter Fehler"
                    let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                    completion(.failure(error)) // Serverfehler
                }
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unerwartete Antwort"])))
            }
        }
        task.resume()
    }
    
    // Übersetzt ein Protokoll
    func translateRecordMeetingLang(meetingId: UUID, lang1: String, lang2: String, completion: @escaping (Result<Void, Error>) -> Void) {
        errorMessage = nil
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/\(meetingId.uuidString)/records/\(lang1)/translate/\(lang2)") else {
            print("Invalid URL")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Unauthorized: No token found")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unauthorized: No token found"])))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error)) // Netzwerkfehler
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    completion(.success(())) // Erfolg
                } else {
                    let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unbekannter Fehler"
                    let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                    completion(.failure(error)) // Serverfehler
                }
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unerwartete Antwort"])))
            }
        }
        task.resume()
    }

    // Protokoll einreichen
    func submitRecordMeetingLang(meetingId: UUID, lang: String, completion: @escaping (Result<Void, Error>) -> Void) {
        errorMessage = nil
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/\(meetingId.uuidString)/records/\(lang)/submit") else {
            print("Invalid URL")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Unauthorized: No token found")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unauthorized: No token found"])))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error)) // Netzwerkfehler
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    completion(.success(())) // Erfolg
                } else {
                    let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unbekannter Fehler"
                    let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                    completion(.failure(error)) // Serverfehler
                }
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unerwartete Antwort"])))
            }
        }
        task.resume()
    }
    
    // Protokoll veröffentlichen
    func approveRecordMeetingLang(meetingId: UUID, lang: String, completion: @escaping (Result<Void, Error>) -> Void) {
        errorMessage = nil
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/\(meetingId.uuidString)/records/\(lang)/approve") else {
            print("Invalid URL")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Unauthorized: No token found")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unauthorized: No token found"])))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error)) // Netzwerkfehler
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    completion(.success(())) // Erfolg
                } else {
                    let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unbekannter Fehler"
                    let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                    completion(.failure(error)) // Serverfehler
                }
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unerwartete Antwort"])))
            }
        }
        task.resume()
    }
}
