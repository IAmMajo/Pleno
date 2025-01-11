import Combine
import AuthServiceDTOs
import Foundation
import MeetingServiceDTOs


class UserManager: ObservableObject {
    @Published var users: [UserProfileDTO] = [] // Beobachtbare Benutzerliste

    func fetchUsers() {
        // Abrufen der Benutzerprofile (siehe vorherige Implementierung)
        fetchUsers { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedUsers):
                    self?.users = fetchedUsers.filter { user in
                        if let isActive = user.isActive {
                            return isActive
                        }
                        return false // Wenn isActive nil ist, wird der Benutzer ausgeschlossen
                    }
                case .failure(let error):
                    print("Fehler beim Abrufen der Benutzer: \(error.localizedDescription)")
                }
            }
        }
    }

    private func fetchUsers(completion: @escaping (Result<[UserProfileDTO], Error>) -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/users") else {
            //completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            //completion(.failure(APIError.unauthorized))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                  let data = data else {
                //completion(.failure(APIError.invalidResponse))
                return
            }

            do {
                let decoder = JSONDecoder()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                decoder.dateDecodingStrategy = .formatted(formatter)

                let users = try decoder.decode([UserProfileDTO].self, from: data)
                completion(.success(users))
                print(users)
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    var user: UserProfileDTO?
    func getUser(userId: UUID){
        // Erstelle die URL für die Anfrage
        guard let url = URL(string: "https://kivop.ipv64.net/users/\(userId)") else {
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
                print("Das ist es: -------------------- Server Response: \(jsonString)")
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            do {
                // Dekodiere das einzelne Record-Objekt
                let decodedUser = try decoder.decode(UserProfileDTO.self, from: data)
                DispatchQueue.main.async {
                    self?.user = decodedUser // Den User speichern
                }
            } catch {
                print("JSON Decode Error: \(error.localizedDescription)")
            }
        }.resume()
    }
    var userIdentity: GetIdentityDTO?
    func getUserIdentity(userId: UUID) async {
        // Erstelle die URL für die Anfrage
        guard let url = URL(string: "https://kivop.ipv64.net/users/identities/\(userId)") else {
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

        do {
            // Sende die Anfrage und hole die Antwort
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Überprüfe den Statuscode der Antwort
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response or status code")
                return
            }

            // Debugging: Serverantwort in Klartext ausgeben
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Server Response: \(jsonString)")
            }

            // Dekodiere das Antwort-Datenobjekt
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            let decodedUserIdentity = try decoder.decode(GetIdentityDTO.self, from: data)

            // Stelle sicher, dass du auf dem Hauptthread arbeitest, wenn du auf UI zugreifst
            DispatchQueue.main.async {
                self.userIdentity = decodedUserIdentity // Die Identität speichern
            }
            
        } catch {
            // Fehlerbehandlung
            print("Fehler beim Abrufen der Benutzeridentität: \(error.localizedDescription)")
        }
    }

    
}
