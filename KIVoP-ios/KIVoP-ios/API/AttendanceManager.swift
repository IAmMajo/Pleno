import Combine
import Foundation
import MeetingServiceDTOs

class AttendanceManager: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var attendances: [GetAttendanceDTO] = [] // Records-Array
    
    static let shared = AttendanceManager()

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
    
    private func createAuthorizedRequest(url: URL, method: String, contentType: String = "application/json") -> URLRequest? {
       var request = URLRequest(url: url)
       request.httpMethod = method
       request.setValue(contentType, forHTTPHeaderField: "Content-Type")
       
       if let token = UserDefaults.standard.string(forKey: "jwtToken") {
          request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
       } else {
          return nil
       }
       return request
    }
    
    func fetchIdentityImage(userId: UUID, completion: @escaping (Result<Data, Error>) -> Void) {
       let profileImageBaseURL = "https://kivop.ipv64.net/users/profile-image/identity"
       guard let url = URL(string: "\(profileImageBaseURL)/\(userId.uuidString)") else {
          completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
          return
       }
       
       guard let request = createAuthorizedRequest(url: url, method: "GET") else {
          completion(.failure(NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)))
          return
       }
       
       URLSession.shared.dataTask(with: request) { data, _, error in
          if let error = error {
             completion(.failure(error))
             return
          }
          
          guard let data = data else {
             completion(.failure(NSError(domain: "No data received", code: 500, userInfo: nil)))
             return
          }
          
          completion(.success(data))
       }.resume()
    }
    func fetchIdentityImageAsync(userId: UUID) async throws -> Data {
       try await withCheckedThrowingContinuation { continuation in
          fetchIdentityImage(userId: userId) { result in
             switch result {
             case .success(let data):
                continuation.resume(returning: data)
             case .failure(let error):
                continuation.resume(throwing: error)
             }
          }
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
}
