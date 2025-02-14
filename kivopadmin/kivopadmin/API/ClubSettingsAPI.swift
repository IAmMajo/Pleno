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


import Foundation
import SwiftUI

class ClubSettingsAPI {
    static let shared = ClubSettingsAPI()
    private let baseURL = "https://kivop.ipv64.net/config"

    // MARK: - Fetch All Settings (GET /config)
    func fetchAllSettings(completion: @escaping (Result<[ClubSetting], Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            print("❌ [ClubSettingsAPI] Fehler: Ungültige URL")
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let token = UserDefaults.standard.string(forKey: "jwtToken"), !token.isEmpty else {
            print("❌ [ClubSettingsAPI] Fehler: Kein JWT-Token gefunden.")
            completion(.failure(NSError(domain: "Unauthorized", code: 401, userInfo: nil)))
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        print("📡 [ClubSettingsAPI] GET \(url.absoluteString)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            self.debugResponse(response: response, data: data, error: error)

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: 500, userInfo: nil)))
                return
            }

            // ✅ **Sonderfall: 401 Unauthorized**
            if httpResponse.statusCode == 401 {
                print("❌ [ClubSettingsAPI] Fehler: Token ist ungültig oder abgelaufen.")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name("TokenExpired"), object: nil)
                }
                completion(.failure(NSError(domain: "Unauthorized", code: 401, userInfo: ["message": "Token abgelaufen oder ungültig"])))
                return
            }

            // ✅ **Sonderfall: Falls Backend eine JSON-Fehlermeldung sendet**
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 500, userInfo: nil)))
                return
            }

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let error = jsonObject?["error"] as? Bool, error == true {
                    let reason = jsonObject?["reason"] as? String ?? "Unbekannter Fehler"
                    print("❌ [ClubSettingsAPI] Fehler vom Server: \(reason)")
                    completion(.failure(NSError(domain: "Server Error", code: httpResponse.statusCode, userInfo: ["message": reason])))
                    return
                }

                // ✅ JSON-Dekodierung für Einstellungen
                let settings = try JSONDecoder().decode([ClubSetting].self, from: data)
                print("✅ [ClubSettingsAPI] Erfolgreich geladen: \(settings.count) Einstellungen")
                completion(.success(settings))
            } catch {
                print("❌ [ClubSettingsAPI] JSON-Dekodierungsfehler: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }


    // MARK: - Update a Single Setting (PATCH /config/{id})
    func updateSetting(id: String, newValue: String, completion: @escaping (Result<ClubSetting, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(id)") else {
            print("❌ [ClubSettingsAPI] Fehler: Ungültige URL")
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let token = UserDefaults.standard.string(forKey: "jwtToken"), !token.isEmpty else {
            print("❌ [ClubSettingsAPI] Fehler: Kein JWT-Token gefunden.")
            completion(.failure(NSError(domain: "Unauthorized", code: 401, userInfo: nil)))
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body = ["value": newValue]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("❌ [ClubSettingsAPI] Fehler beim Kodieren der JSON-Daten: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        print("📡 [ClubSettingsAPI] PATCH \(url.absoluteString) mit Body: \(body)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            self.debugResponse(response: response, data: data, error: error)

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 500, userInfo: nil)))
                return
            }

            do {
                let updatedSetting = try JSONDecoder().decode(ClubSetting.self, from: data)
                print("✅ [ClubSettingsAPI] Erfolgreich aktualisiert: \(updatedSetting)")
                completion(.success(updatedSetting))
            } catch {
                print("❌ [ClubSettingsAPI] JSON-Dekodierungsfehler: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Bulk Update Settings (PATCH /config)
    func bulkUpdateSettings(updates: [SettingUpdate], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            print("❌ [ClubSettingsAPI] Fehler: Ungültige URL")
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let token = UserDefaults.standard.string(forKey: "jwtToken"), !token.isEmpty else {
            print("❌ [ClubSettingsAPI] Fehler: Kein JWT-Token gefunden.")
            completion(.failure(NSError(domain: "Unauthorized", code: 401, userInfo: nil)))
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body = ["updates": updates.map { ["id": $0.id, "value": $0.value] }]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("❌ [ClubSettingsAPI] Fehler beim Kodieren der JSON-Daten: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        print("📡 [ClubSettingsAPI] PATCH \(url.absoluteString) mit Body: \(body)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            self.debugResponse(response: response, data: data, error: error)

            if let error = error {
                completion(.failure(error))
                return
            }

            completion(.success(()))
        }.resume()
    }

    // MARK: - Debugging-Methode für Serverantworten
    private func debugResponse(response: URLResponse?, data: Data?, error: Error?) {
        if let error = error {
            print("❌ [ClubSettingsAPI] Netzwerkfehler: \(error.localizedDescription)")
            return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ [ClubSettingsAPI] Fehler: Keine gültige HTTP-Antwort erhalten")
            return
        }

        print("🔍 [ClubSettingsAPI] HTTP-Statuscode: \(httpResponse.statusCode)")

        if let data = data, let responseText = String(data: data, encoding: .utf8) {
            print("📥 [ClubSettingsAPI] Serverantwort:\n\(responseText)")
        } else {
            print("❌ [ClubSettingsAPI] Keine Daten empfangen")
        }
    }
}
