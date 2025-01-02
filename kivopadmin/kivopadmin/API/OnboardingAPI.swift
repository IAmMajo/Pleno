//
//  OnboardingAPI.swift
//  KIVoP-ios
//
//

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
        completion: @escaping (Result<Void, Error>) -> Void
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
                completion(.success(()))
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
}


