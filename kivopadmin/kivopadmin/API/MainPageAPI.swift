//
//  MainPageAPI.swift
//  KIVoP-ios
//
//  Created by Amine Ahamri on 25.11.24.
//

import Foundation
import AuthServiceDTOs
import MeetingServiceDTOs
import UIKit

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
        request.httpMethod = "PUT"
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

    // MARK: - Fehlerarten
    enum APIError: Error {
        case invalidURL
        case invalidResponse
        case invalidRequest
        case invalidData
        case unknown
    }
}


public struct UserPasswordUpdateDTO: Codable {
    public var currentPassword: String
    public var newPassword: String

    public init(currentPassword: String, newPassword: String) {
        self.currentPassword = currentPassword
        self.newPassword = newPassword
    }
}
