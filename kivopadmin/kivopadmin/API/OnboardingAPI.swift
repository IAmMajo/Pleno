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
//  OnboardingAPI.swift
//  KIVoP-ios
//
//
// This file is licensed under the MIT-0 License.
import Foundation
import AuthServiceDTOs

class OnboardingAPI {
    
    static let baseURL = "https://kivop.ipv64.net"
    
    /// Registriert einen neuen Benutzer.
    /// - Parameters:
    ///   - registrationDTO: Die Daten für die Registrierung.
    ///   - completion: Callback mit einem optionalen Fehler und einer Erfolgsmeldung.
    static func registerUser(
        with registrationDTO: UserRegistrationDTO,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/users/register") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ungültige URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(registrationDTO)
            request.httpBody = jsonData
        } catch {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Fehler beim Verarbeiten der Daten."])))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ungültige Antwort vom Server."])))
                return
            }

            if httpResponse.statusCode == 201 {
                // Registrierung erfolgreich
                print("Registrierung erfolgreich.")
                completion(.success("Registrierung erfolgreich."))
            } else {
                let errorMessage = "Registrierung fehlgeschlagen. Status: \(httpResponse.statusCode)"
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
            }
        }.resume()
    }
    
    /// Loggt einen Benutzer ein.
    /// - Parameters:
    ///   - loginDTO: Die Login-Daten.
    ///   - completion: Callback mit einem optionalen Fehler und einem optionalen JWT-Token.
    static func loginUser(
        with loginDTO: UserLoginDTO,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ungültige URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(loginDTO)
            request.httpBody = jsonData
        } catch {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Fehler beim Verarbeiten der Daten."])))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ungültige Antwort vom Server."])))
                return
            }
            
            if httpResponse.statusCode == 200, let data = data {
                do {
                    let tokenResponse = try JSONDecoder().decode(TokenResponseDTO.self, from: data)
                    if let token = tokenResponse.token {
                        completion(.success(token))
                    } else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ungültige Antwort vom Server."])))
                    }
                } catch {
                    completion(.failure(error))
                }
            } else {
                let errorMessage = "Login fehlgeschlagen. Status: \(httpResponse.statusCode)"
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
            }
        }.resume()
    }
    
    /// Überprüft, ob die E-Mail verifiziert wurde.
    static func checkEmailVerification(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/email/status") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ungültige URL."])))
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
                  let data = data,
                  let json = try? JSONDecoder().decode([String: Bool].self, from: data),
                  let emailVerified = json["emailVerified"] else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Fehler beim Verarbeiten der Antwort."])))
                return
            }
            
            completion(.success(emailVerified))
        }.resume()
    }
    
    /// Überprüft, ob der Benutzer vom Organisator akzeptiert wurde.
    static func checkUserAcceptedStatus(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/profile") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ungültige URL."])))
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
                  let data = data,
                  let profile = try? JSONDecoder().decode(UserProfileDTO.self, from: data) else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Fehler beim Verarbeiten der Antwort."])))
                return
            }
            
            completion(.success(profile.isAdmin ?? false))
        }.resume()
    }
    
    static func sendResetCode(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/users/password/reset-request"),
              let jsonData = try? JSONSerialization.data(withJSONObject: ["email": email]) else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Ungültige Anfrage"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Fehler beim Senden des Reset-Codes"])))
                return
            }

            completion(.success(()))
        }.resume()
    }
    
    
    static func resetPassword(email: String, resetCode: String, newPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/password/reset"),
              let jsonData = try? JSONSerialization.data(withJSONObject: [
                  "email": email,
                  "resetCode": resetCode,
                  "newPassword": newPassword
              ]) else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Ungültige Anfrage"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Fehler beim Zurücksetzen des Passworts"])))
                return
            }

            // Automatischer Login nach erfolgreichem Passwort-Reset
            let loginDTO = UserLoginDTO(email: email, password: newPassword)
            loginUser(with: loginDTO) { loginResult in
                switch loginResult {
                case .success(let token):
                    UserDefaults.standard.setValue(token, forKey: "jwtToken")
                    completion(.success(()))
                case .failure(let loginError):
                    completion(.failure(loginError))
                }
            }
        }.resume()
    }
    
    static func resendVerificationEmail(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/users/email/resend/\(email)") else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Ungültige URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Fehler beim erneuten Senden der Verifizierungs-E-Mail"])))
                return
            }

            completion(.success(()))
        }.resume()
    }

}


