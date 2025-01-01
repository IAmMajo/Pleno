//
//  AuthController.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 25.11.24.
//

import Foundation
import AuthServiceDTOs

class AuthController: ObservableObject {
    
    private let baseURL = "https://kivop.ipv64.net"
    private let loginEndpoint = "/auth/login"
    private let tokenVerifyEndpoint = "/auth/token-verify"
    
    // Singleton Pattern, damit auf den AuthController global zugegriffen werden kann
    static let shared = AuthController()
    
    private init() {}
    
    // Funktion zum Einloggen des Benutzers und Speichern des Tokens in UserDefaults
    func login(email: String, password: String) async throws {
        let loginDTO = UserLoginDTO(email: email, password: password)
        
        guard let url = URL(string: baseURL + loginEndpoint) else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // JSON-Encoding der DTO-Daten
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(loginDTO)
        
        // URLSession zum Senden der Anfrage
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Überprüfen, ob der Statuscode 200 OK ist
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "Login failed", code: 500, userInfo: nil)
        }
        
        // Antwort-Daten in TokenResponseDTO umwandeln
        let decoder = JSONDecoder()
        let tokenResponse = try decoder.decode(TokenResponseDTO.self, from: data)
        
        // Token, Email und Passwort in UserDefaults speichern
        if let token = tokenResponse.token {
            UserDefaults.standard.set(token, forKey: "userToken")
            UserDefaults.standard.set(email, forKey: "userEmail")
            UserDefaults.standard.set(password, forKey: "userPassword")
        } else {
            throw NSError(domain: "Token not found", code: 500, userInfo: nil)
        }
    }
    
    // Funktion zur Verifizierung eines gegebenen Tokens
    func verifyToken(token: String) async throws -> Bool {
        guard let url = URL(string: baseURL + tokenVerifyEndpoint) else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "Invalid response", code: 500, userInfo: nil)
        }
        
        return httpResponse.statusCode == 200
    }
    
    // Token holen und ggf. erneuern
    func getAuthToken() async throws -> String {
        // Gespeicherten Token zu holen und zu prüfen
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            if try await verifyToken(token: token) {
                return token // Falls Token gültig wird dieser zurückgegeben
            }
        }
        
        // Token ist ungültig oder nicht vorhanden, daher neuen Token holen
        guard let email = UserDefaults.standard.string(forKey: "userEmail"),
              let password = UserDefaults.standard.string(forKey: "userPassword") else {
            throw NSError(domain: "Credentials not found", code: 401, userInfo: nil)
        }
        
        // Durch Login wird neuer Token gesetzt
        try await login(email: email, password: password)
        
        // Versuche, den neuen Token zu holen
        if let newToken = UserDefaults.standard.string(forKey: "userToken") {
            return newToken
        }
        // Wenn kein Token verfügbar ist, Fehler werfen
        throw NSError(domain: "Failed to fetch token after login", code: 500, userInfo: nil)
    }
}

