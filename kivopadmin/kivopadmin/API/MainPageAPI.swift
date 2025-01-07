//
//  MainPageAPI.swift
//  KIVoP-ios
//
//

import Foundation
import AuthServiceDTOs
import MeetingServiceDTOs
import UIKit

let baseURL = "https://kivop.ipv64.net"


struct MainPageAPI {
    
    // MARK: - Benutzerprofil abrufen
       static func fetchUserProfile(completion: @escaping (Result<UserProfileDTO, Error>) -> Void) {
           guard let url = URL(string: "https://kivop.ipv64.net/users/profile") else {
               completion(.failure(APIError.invalidURL))
               return
           }

           var request = URLRequest(url: url)
           request.httpMethod = "GET"
           request.addValue("Bearer \(UserDefaults.standard.string(forKey: "jwtToken") ?? "")", forHTTPHeaderField: "Authorization")

           URLSession.shared.dataTask(with: request) { data, response, error in
               if let error = error {
                   completion(.failure(error))
                   return
               }

               guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                     let data = data else {
                   completion(.failure(APIError.invalidResponse))
                   return
               }

               // Debugging: JSON überprüfen
               if let jsonString = String(data: data, encoding: .utf8) {
                   print("API Response JSON: \(jsonString)")
               }

               do {
                   let decoder = JSONDecoder()
                   let formatter = DateFormatter()
                   formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Beispiel ISO 8601
                   decoder.dateDecodingStrategy = .formatted(formatter)

                   let profile = try decoder.decode(UserProfileDTO.self, from: data)
                   completion(.success(profile))
               } catch {
                   print("JSON Decoding Error: \(error.localizedDescription)")
                   completion(.failure(error))
               }
           }.resume()
       }

    // MARK: - Benutzerkonto löschen
    static func deleteUserAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/users") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "jwtToken") ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(APIError.invalidResponse))
                return
            }

            completion(.success(()))
        }.resume()
    }

    // MARK: - Benutzer abmelden
    static func logoutUser() {
        UserDefaults.standard.removeObject(forKey: "jwtToken")
    }

    // MARK: - Aktuelles Meeting abrufen
    static func fetchCurrentMeeting(completion: @escaping (Result<GetMeetingDTO?, Error>) -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/meetings") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "jwtToken") ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                  let data = data else {
                completion(.failure(APIError.invalidResponse))
                return
            }

            do {
                let meetings = try JSONDecoder().decode([GetMeetingDTO].self, from: data)
                completion(.success(meetings.first))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Benutzernamen Updaten
    static func updateUserName(name: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/users/identity") else {
            print("Fehler: Ungültige URL")
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Fehler: Kein JWT-Token gefunden")
            completion(.failure(APIError.invalidRequest))
            return
        }

        let updateDTO = UserProfileUpdateDTO(name: name)

        do {
            let jsonData = try JSONEncoder().encode(updateDTO)
            request.httpBody = jsonData
            // Debug: JSON-Body prüfen
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Request JSON: \(jsonString)")
            } else {
                print("Fehler: JSON konnte nicht erstellt werden")
            }
        } catch {
            print("Fehler beim Serialisieren des DTO: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Netzwerkfehler: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                // Debug: Status Code und Header prüfen
                print("Status Code: \(httpResponse.statusCode)")
                print("Response Headers: \(httpResponse.allHeaderFields)")

                if httpResponse.statusCode == 200 {
                    print("Name erfolgreich aktualisiert.")
                    completion(.success(()))
                } else {
                    // Debug: Fehlerhafte Antwort
                    if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                        print("Fehlerhafte Antwort: \(responseBody)")
                    }
                    completion(.failure(APIError.invalidResponse))
                }
            } else {
                print("Fehler: Ungültige Serverantwort")
                completion(.failure(APIError.invalidResponse))
            }
        }.resume()
    }

    // MARK: - Passwort aktualisieren/ändern
    static func updatePassword(currentPassword: String, newPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
            guard let url = URL(string: "https://kivop.ipv64.net/users/password/reset") else {
                completion(.failure(APIError.invalidURL))
                return
            }

            let passwordUpdateDTO = UserPasswordUpdateDTO(
                currentPassword: currentPassword,
                newPassword: newPassword
            )

            guard let jsonData = try? JSONEncoder().encode(passwordUpdateDTO) else {
                completion(.failure(APIError.invalidRequest))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Bearer \(UserDefaults.standard.string(forKey: "jwtToken") ?? "")", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(APIError.invalidResponse))
                    return
                }

                if httpResponse.statusCode == 200 {
                    completion(.success(()))
                } else {
                    completion(.failure(APIError.unknown))
                }
            }.resume()
        }

    // MARK: - Helferfunktionen
    static func calculateShortName(from fullName: String) -> String {
        let nameParts = fullName.split(separator: " ")
        guard let firstInitial = nameParts.first?.prefix(1),
              let lastInitial = nameParts.last?.prefix(1) else {
            return "??"
        }
        return "\(firstInitial)\(lastInitial)".uppercased()
    }
    
    // MARK: - Profilbild
    static func fetchProfilePicture(completion: @escaping (Result<UIImage, Error>) -> Void) {
            guard let url = URL(string: "https://kivop.ipv64.net/users/profile/picture") else {
                completion(.failure(APIError.invalidURL))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(UserDefaults.standard.string(forKey: "jwtToken") ?? "")", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                      let data = data, let image = UIImage(data: data) else {
                    completion(.failure(APIError.invalidResponse))
                    return
                }

                completion(.success(image))
            }.resume()
        }

        static func uploadProfilePicture(image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
            guard let url = URL(string: "https://kivop.ipv64.net/users/profile/picture") else {
                completion(.failure(APIError.invalidURL))
                return
            }

            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                completion(.failure(APIError.invalidData))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.addValue("Bearer \(UserDefaults.standard.string(forKey: "jwtToken") ?? "")", forHTTPHeaderField: "Authorization")
            request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")
            request.httpBody = imageData

            URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(.failure(APIError.invalidResponse))
                    return
                }

                completion(.success(()))
            }.resume()
        }

        static func deleteProfilePicture(completion: @escaping (Result<Void, Error>) -> Void) {
            guard let url = URL(string: "https://kivop.ipv64.net/users/profile/picture") else {
                completion(.failure(APIError.invalidURL))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.addValue("Bearer \(UserDefaults.standard.string(forKey: "jwtToken") ?? "")", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(.failure(APIError.invalidResponse))
                    return
                }

                completion(.success(()))
            }.resume()
        }
    
    static func fetchPendingUsers(completion: @escaping (Result<[UserProfileDTO], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users") else {
            print("❌ Fehler: Ungültige URL für fetchPendingUsers.")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ungültige URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "jwtToken") ?? "")", forHTTPHeaderField: "Authorization")

        print("➡️ Sende GET-Anfrage an URL: \(url)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Netzwerkfehler in fetchPendingUsers: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("ℹ️ Antwortstatus von fetchPendingUsers: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("❌ Keine Daten von fetchPendingUsers erhalten.")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Keine Daten erhalten."])))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let users = try decoder.decode([UserProfileDTO].self, from: data)
                print("✅ Erfolgreich \(users.count) Nutzerprofile abgerufen.")
                completion(.success(users))
            } catch {
                print("❌ Fehler beim Dekodieren von fetchPendingUsers: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }



    static func activateUser(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/\(userId)") else {
            print("❌ Fehler: Ungültige URL für activateUser.")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ungültige URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "jwtToken") ?? "")", forHTTPHeaderField: "Authorization")

        let body = ["isActive": true]
        do {
            request.httpBody = try JSONEncoder().encode(body)
            if let jsonString = String(data: request.httpBody ?? Data(), encoding: .utf8) {
                print("➡️ Sende PATCH-Anfrage an URL: \(url) mit Body: \(jsonString)")
            }
        } catch {
            print("❌ Fehler beim Erstellen des JSON-Bodys für activateUser: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("❌ Netzwerkfehler in activateUser: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("ℹ️ Antwortstatus von activateUser: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    print("✅ Nutzer erfolgreich aktiviert.")
                    completion(.success(()))
                } else {
                    print("❌ Fehler beim Aktivieren des Nutzers: Status \(httpResponse.statusCode)")
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Fehler beim Aktivieren des Nutzers."])))
                }
            }
        }.resume()
    }
    
    static func deleteUser(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/\(userId)") else {
            print("❌ Fehler: Ungültige URL für deleteUser.")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ungültige URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "jwtToken") ?? "")", forHTTPHeaderField: "Authorization")

        print("➡️ Sende DELETE-Anfrage an URL: \(url)")

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("❌ Netzwerkfehler in deleteUser: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("ℹ️ Antwortstatus von deleteUser: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    print("✅ Nutzer erfolgreich gelöscht.")
                    completion(.success(()))
                } else {
                    print("❌ Fehler beim Löschen des Nutzers: Status \(httpResponse.statusCode)")
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Fehler beim Löschen des Nutzers."])))
                }
            }
        }.resume()
    }

    
    // MARK: - Alle Benutzer laden
    static func fetchAllUsers(completion: @escaping (Result<[UserProfileDTO], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users") else {
            print("❌ Fehler: Ungültige URL für Benutzerliste.")
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "jwtToken") ?? "")", forHTTPHeaderField: "Authorization")

        print("➡️ Sende GET-Anfrage an URL: \(url)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Netzwerkfehler in fetchAllUsers: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("ℹ️ Antwortstatus von fetchAllUsers: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                print("❌ Keine Daten von fetchAllUsers erhalten.")
                completion(.failure(APIError.invalidData))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let users = try decoder.decode([UserProfileDTO].self, from: data)
                print("✅ Erfolgreich \(users.count) Benutzer geladen:")
                users.forEach { print("👤 Benutzer: \(String(describing: $0.name)) - \(String(describing: $0.email))") }
                completion(.success(users))
            } catch {
                print("❌ Fehler beim Dekodieren von fetchAllUsers: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Einzelnen Benutzer abrufen
    static func fetchUserByID(userID: UUID, completion: @escaping (Result<UserProfileDTO, Error>) -> Void) {
           let urlString = "\(baseURL)/users/\(userID)"
           guard let url = URL(string: urlString) else {
               print("❌ Ungültige URL: \(urlString)")
               completion(.failure(APIError.invalidURL))
               return
           }

           var request = URLRequest(url: url)
           request.httpMethod = "GET"
           request.addValue("Bearer \(UserDefaults.standard.string(forKey: "jwtToken") ?? "")", forHTTPHeaderField: "Authorization")

           print("➡️ Sende GET-Anfrage für Benutzer mit ID \(userID) an URL: \(url)")

           URLSession.shared.dataTask(with: request) { data, response, error in
               if let error = error {
                   print("❌ Netzwerkfehler: \(error.localizedDescription)")
                   completion(.failure(error))
                   return
               }

               guard let data = data else {
                   print("❌ Keine Daten empfangen.")
                   completion(.failure(APIError.invalidResponse))
                   return
               }

               // Debug: Response-Daten prüfen
               if let responseString = String(data: data, encoding: .utf8) {
                   print("📝 Serverantwort JSON: \(responseString)")
               }

               do {
                   let decoder = JSONDecoder()
                   let formatter = DateFormatter()
                   formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                   decoder.dateDecodingStrategy = .formatted(formatter)

                   let user = try decoder.decode(UserProfileDTO.self, from: data)
                   print("✅ Benutzer erfolgreich dekodiert: \(user.name ?? "Unbekannt")")
                   completion(.success(user))
               } catch {
                   print("❌ Fehler beim Dekodieren des Benutzers: \(error.localizedDescription)")
                   completion(.failure(error))
               }
           }.resume()
       }
    
    // MARK: - Admin-Status aktualisieren
    static func updateAdminStatus(userId: String, isAdmin: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/\(userId)") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "jwtToken") ?? "")", forHTTPHeaderField: "Authorization")

        let body = ["isAdmin": isAdmin]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(APIError.invalidResponse))
                return
            }

            completion(.success(()))
        }.resume()
    }



    static func calculateInitials(from fullName: String?) -> String {
        guard let name = fullName, !name.isEmpty else { return "??" }
        let nameParts = name.split(separator: " ")

        if nameParts.count >= 2 {
            let firstInitial = nameParts.first?.prefix(1) ?? ""
            let lastInitial = nameParts.last?.prefix(1) ?? ""
            return "\(firstInitial)\(lastInitial)".uppercased()
        } else {
            return String(name.prefix(2)).uppercased()
        }
    }



    }


    // MARK: - Fehlerarten
    enum APIError: Error {
        case invalidURL
        case invalidResponse
        case invalidRequest
        case invalidData
        case unknown
    }



public struct UserPasswordUpdateDTO: Codable {
    public var currentPassword: String
    public var newPassword: String

    public init(currentPassword: String, newPassword: String) {
        self.currentPassword = currentPassword
        self.newPassword = newPassword
    }
}
