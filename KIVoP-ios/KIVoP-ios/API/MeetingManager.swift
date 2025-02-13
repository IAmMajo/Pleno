import Combine
import Foundation
import MeetingServiceDTOs

// ViewModel für Sitzungen
class MeetingManager: ObservableObject {
    // Statusanzeige, ob das ViewModel lädt
    @Published var isLoading: Bool = false
    
    // Variable für potentielle Fehlermeldungen
    @Published var errorMessage: String? = nil

    @Published var meetings: [GetMeetingDTO] = [] // Meetings-Array
    @Published var currentMeeting: GetMeetingDTO?  // Meeting-Array

    // Lädt alle Sitzungen vom Server
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
                do{
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
                    
                    let decoder = JSONDecoder()
                    
                    // Falls du mit Date-Formaten arbeitest, musst du das Datumsformat konfigurieren:
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                    decoder.dateDecodingStrategy = .formatted(formatter)
                    
                    // Dekodiere die Daten
                    self?.meetings = try decoder.decode([GetMeetingDTO].self, from: data)
                    self?.getCurrentMeeting()

                }catch {
                    self?.errorMessage = "Failed to decode meetings: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
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
    
    // Funktion zum Abrufen eines einzelnen Meetings anhand der ID
    func getSingleMeeting(meetingId: UUID, completion: @escaping (Result<GetMeetingDTO, Error>) -> Void) {
        errorMessage = nil
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
}
