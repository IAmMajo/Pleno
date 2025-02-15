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
                switch httpResponse.statusCode {
                case 200:
                    completion(.success(()))
                case 423:
                    // Fehler 423 korrekt behandeln
                    let lockedError = NSError(domain: "", code: 423, userInfo: [NSLocalizedDescriptionKey: "Während eines Meetings lassen sich Username und Profilbild nicht ändern."])
                    completion(.failure(lockedError))
                default:
                    completion(.failure(APIError.invalidResponse))
                }
                return
            }

            completion(.failure(APIError.invalidResponse))
        }.resume()
    }

    // MARK: - Profilbild aktualisieren
    static func updateUserProfileImage(profileImage: UIImage?, completion: @escaping (Result<Void, Error>) -> Void) {
        print("[DEBUG] Profilbild-Update gestartet.")
        
        // URL erstellen
        guard let url = URL(string: "https://kivop.ipv64.net/users/profile") else {
            print("[DEBUG] Fehler: Ungültige URL.")
            completion(.failure(APIError.invalidURL))
            return
        }
        print("[DEBUG] URL für Profilbild-Update: \(url)")
        
        // JWT-Token abrufen
        guard let jwtToken = UserDefaults.standard.string(forKey: "jwtToken") else {
            print("[DEBUG] Fehler: Kein JWT-Token gefunden.")
            completion(.failure(APIError.missingToken))
            return
        }
        print("[DEBUG] JWT-Token abgerufen: \(jwtToken.prefix(10))...") // Token maskiert
        
        // HTTP-Request erstellen
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        print("[DEBUG] HTTP-Header gesetzt.")
        
        // Bilddaten oder explizites Null-Objekt vorbereiten
        let updateDTO: [String: Any]
        if let image = profileImage, let imageData = image.jpegData(compressionQuality: 0.6) {
            updateDTO = ["profileImage": imageData.base64EncodedString()] // Base64 für JSON
            print("[DEBUG] Profilbild wird aktualisiert.")
        } else {
            updateDTO = ["profileImage": ""] // Explizit `null` senden
            print("[DEBUG] Profilbild wird gelöscht.")
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: updateDTO, options: [])
            request.httpBody = jsonData
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("[DEBUG] Encodiertes JSON: \(jsonString)")
            }
        } catch {
            print("[DEBUG] Fehler beim Encodieren des JSON: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        // API-Request ausführen
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("[DEBUG] Netzwerkfehler: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("[DEBUG] Fehler: Keine gültige HTTP-Antwort erhalten.")
                completion(.failure(APIError.invalidResponse))
                return
            }
            
            print("[DEBUG] HTTP-Statuscode: \(httpResponse.statusCode)")
            
            if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                print("[DEBUG] Antwort-Body: \(responseBody)")
            }
            
            switch httpResponse.statusCode {
            case 200:
                print("[DEBUG] Profilbild-Update erfolgreich.")
                completion(.success(()))
            case 423:
                print("[DEBUG] Fehler: Benutzername/Profilbild kann während eines Meetings nicht geändert werden.")
                let lockedError = NSError(domain: "", code: 423, userInfo: [NSLocalizedDescriptionKey: "Während eines Meetings lassen sich Username und Profilbild nicht ändern."])
                completion(.failure(lockedError))
            default:
                print("[DEBUG] Fehler: Unerwarteter Statuscode \(httpResponse.statusCode).")
                completion(.failure(APIError.invalidResponse))
            }
        }.resume()
    }




    // MARK: - Passwort aktualisieren/ändern
    static func updatePassword(currentPassword: String, newPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // URL anpassen entsprechend Swagger-Dokumentation
        guard let url = URL(string: "https://kivop.ipv64.net/users/change-password") else {
            print("[DEBUG] Fehler: Ungültige URL.")
            completion(.failure(APIError.invalidURL))
            return
        }

        print("[DEBUG] URL für Passwortänderung: \(url)")

        // Request-Body entsprechend dem Swagger-Schema erstellen
        let passwordUpdateDTO = [
            "oldPassword": currentPassword,
            "newPassword": newPassword
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: passwordUpdateDTO, options: []) else {
            print("[DEBUG] Fehler: JSON-Serialisierung des Request-Bodys fehlgeschlagen.")
            completion(.failure(APIError.invalidRequest))
            return
        }

        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("[DEBUG] JSON-Daten für Passwortänderung: \(jsonString)")
        } else {
            print("[DEBUG] Fehler: JSON-Daten konnten nicht in String umgewandelt werden.")
        }



        // URLRequest konfigurieren
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        let token = UserDefaults.standard.string(forKey: "jwtToken") ?? ""
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        print("[DEBUG] HTTP-Header für Passwortänderung:")
        print("Authorization: Bearer \(token.prefix(10))...") // Token aus Sicherheitsgründen gekürzt
        print("Content-Type: application/json")

        // API-Aufruf durchführen
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("[DEBUG] Netzwerkfehler: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("[DEBUG] Fehler: Keine gültige HTTP-Antwort erhalten.")
                completion(.failure(APIError.invalidResponse))
                return
            }

            print("[DEBUG] HTTP-Statuscode: \(httpResponse.statusCode)")

            // Optional: Body der Antwort für Debugging ausgeben
            if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                print("[DEBUG] Antwort-Body: \(responseBody)")
            }

            // HTTP-Statuscode prüfen
            switch httpResponse.statusCode {
            case 200:
                print("[DEBUG] Passwort erfolgreich geändert.")
                completion(.success(()))
            case 400:
                print("[DEBUG] Fehler: Ungültige Anfrage (400 Bad Request).")
                completion(.failure(APIError.badRequest))
            case 401:
                print("[DEBUG] Fehler: Nicht autorisiert (401 Unauthorized).")
                completion(.failure(APIError.unauthorized))
            default:
                print("[DEBUG] Fehler: Unerwarteter Statuscode \(httpResponse.statusCode).")
                completion(.failure(APIError.unknown))
            }
        }.resume()
    }


    // MARK: - Helferfunktionen
    static func calculateShortName(from fullName: String) -> String {
        let nameParts = fullName.split(separator: " ")
        
        if nameParts.count == 1 {
            // Falls nur ein Name vorhanden ist, verwende die ersten zwei Buchstaben
            return String(nameParts.first!.prefix(2)).uppercased()
        }

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
        case badRequest
        case unauthorized
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
