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
        // Swagger Endpoint für das Löschen des Benutzerkontos
        guard let url = URL(string: "https://kivop.ipv64.net/users/delete") else {
            print("[DEBUG] Ungültige URL")
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        // JWT-Token aus den UserDefaults hinzufügen
        if let jwtToken = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        } else {
            print("[DEBUG] JWT-Token fehlt")
            completion(.failure(APIError.missingToken))
            return
        }

        // HTTP-Request ausführen
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("[DEBUG] Fehler beim Löschen des Accounts: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("[DEBUG] Keine gültige HTTP-Antwort erhalten")
                completion(.failure(APIError.invalidResponse))
                return
            }

            print("[DEBUG] HTTP-Statuscode: \(httpResponse.statusCode)")

            // Überprüfen, ob der HTTP-Statuscode 204 ist
            if httpResponse.statusCode == 204  {
                print("[DEBUG] Account erfolgreich gelöscht")
                UserDefaults.standard.removeObject(forKey: "jwtToken")
                UserDefaults.standard.removeObject(forKey: "jwtToken")
                completion(.success(()))
            } else {
                print("[DEBUG] Unerwarteter Statuscode: \(httpResponse.statusCode)")
                completion(.failure(APIError.invalidResponse))
            }
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
        guard let url = URL(string: "https://kivop.ipv64.net/users/profile") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        guard let jwtToken = UserDefaults.standard.string(forKey: "jwtToken") else {
            print("Fehler: Kein JWT-Token gespeichert!")
            completion(.failure(APIError.invalidRequest))
            return
        }

        print("Verwendetes JWT-Token: \(jwtToken)")

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")

        let updateDTO = UserProfileUpdateDTO(name: name)
        do {
            request.httpBody = try JSONEncoder().encode(updateDTO)
        } catch {
            print("Fehler beim Encoden des JSON: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    completion(.failure(APIError.invalidResponse))
                    return
                }
            }

            completion(.success(()))
        }.resume()
    }
    
    // MARK: - Profilbild aktualisieren
    static func updateUserProfileImage(profileImage: UIImage?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/users/profile") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        guard let jwtToken = UserDefaults.standard.string(forKey: "jwtToken") else {
            completion(.failure(APIError.invalidRequest))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")

        let compressedImageData = profileImage?.jpegData(compressionQuality: 0.6)
        let updateDTO = UserProfileUpdateDTO(name: nil, profileImage: compressedImageData)

        do {
            request.httpBody = try JSONEncoder().encode(updateDTO)
        } catch {
            completion(.failure(error))
            return
        }

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
    

    // MARK: - Fehlerarten
    enum APIError: Error {
        case invalidURL
        case invalidResponse
        case invalidRequest
        case invalidData
        case unknown
        case missingToken
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
