//
//  VotingService.swift
//  kivopadmin
//
//  Created by Amine Ahamri on 28.11.24.
//


import Foundation
import Combine
import MeetingServiceDTOs

class VotingService: ObservableObject {
    static let shared = VotingService()
    
    @Published var votings: [GetVotingDTO] = []
    
    func fetchVotings(completion: @escaping (Result<[GetVotingDTO], Error>) -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/votings") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 500, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let fetchedVotings = try decoder.decode([GetVotingDTO].self, from: data)
                completion(.success(fetchedVotings))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchVotingResults(votingId: UUID, completion: @escaping (Result<GetVotingResultsDTO, Error>) -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/votings/\(votingId)/results") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 500, userInfo: nil)))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let results = try decoder.decode(GetVotingResultsDTO.self, from: data)
                completion(.success(results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func patchVoting(votingId: UUID, patch: PatchVotingDTO, completion: @escaping (Result<GetVotingDTO, Error>) -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/votings/\(votingId)") else {
            let error = NSError(domain: "Invalid URL", code: 400, userInfo: nil)
            print("Fehler: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            let error = NSError(domain: "Unauthorized", code: 401, userInfo: nil)
            print("Fehler: JWT Token fehlt")
            completion(.failure(error))
            return
        }

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(patch)

            // Debugging: Gesendete Daten
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Daten gesendet: \(jsonString)")
            }

            request.httpBody = jsonData
        } catch {
            print("Fehler beim Kodieren der JSON-Daten: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Netzwerkfehler: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "Invalid Response", code: 500, userInfo: nil)
                print("Fehler: Ungültige Serverantwort")
                completion(.failure(error))
                return
            }

            print("HTTP-Statuscode: \(httpResponse.statusCode)")

            guard (200...299).contains(httpResponse.statusCode) else {
                if let data = data, let responseText = String(data: data, encoding: .utf8) {
                    print("Serverfehler: \(responseText)")
                }
                let error = NSError(domain: "Server Error", code: httpResponse.statusCode, userInfo: nil)
                completion(.failure(error))
                return
            }

            guard let data = data else {
                let error = NSError(domain: "No Data", code: 204, userInfo: nil)
                print("Fehler: Keine Daten erhalten")
                completion(.failure(error))
                return
            }

            // Debugging: Serverantwort
            if let responseText = String(data: data, encoding: .utf8) {
                print("Antwortdaten: \(responseText)")
            }

            do {
                let decoder = JSONDecoder()
                let updatedVoting = try decoder.decode(GetVotingDTO.self, from: data)
                print("Erfolgreich aktualisiert: \(updatedVoting)")
                completion(.success(updatedVoting))
            } catch {
                print("Fehler beim Dekodieren der Antwort: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }

    
    func deleteVoting(votingId: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/votings/\(votingId)") else {
            let error = NSError(domain: "Invalid URL", code: 400, userInfo: nil)
            print("Fehler: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            let error = NSError(domain: "Unauthorized", code: 401, userInfo: [NSLocalizedDescriptionKey: "JWT Token fehlt"])
            print("Fehler: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        print("Senden DELETE-Request an URL: \(url)") // Debugging

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Netzwerkfehler beim Löschen: \(error.localizedDescription)") // Debugging
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "Invalid Response", code: 500, userInfo: nil)
                print("Fehler: Keine gültige HTTP-Antwort erhalten.")
                completion(.failure(error))
                return
            }

            print("HTTP-Statuscode: \(httpResponse.statusCode)") // Debugging

            if httpResponse.statusCode == 204 {
                print("Umfrage erfolgreich gelöscht.")
                completion(.success(()))
            } else {
                let errorData = String(data: data ?? Data(), encoding: .utf8) ?? "Keine Daten"
                print("Fehler: HTTP Status \(httpResponse.statusCode), Antwort: \(errorData)")
                let error = NSError(domain: "Server Error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorData])
                completion(.failure(error))
            }
        }.resume()
    }


    func closeVoting(votingId: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/votings/\(votingId)/close") else {
            let error = NSError(domain: "Invalid URL", code: 400, userInfo: nil)
            print("Fehler: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            let error = NSError(domain: "Unauthorized", code: 401, userInfo: [NSLocalizedDescriptionKey: "JWT Token fehlt"])
            print("Fehler: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Fehler bei der Anfrage: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "Invalid Response", code: 500, userInfo: nil)
                print("Fehler: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            if httpResponse.statusCode == 200 {
                print("Abstimmung erfolgreich geschlossen.")
                completion(.success(()))
            } else {
                let errorData = String(data: data ?? Data(), encoding: .utf8) ?? "Keine Daten"
                print("Fehler: HTTP Status \(httpResponse.statusCode), Antwort: \(errorData)")
                let error = NSError(domain: "Server Error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorData])
                completion(.failure(error))
            }
        }.resume()
    }
    
    func createVoting(voting: CreateVotingDTO, completion: @escaping (Result<GetVotingDTO, Error>) -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/votings") else {
            let error = NSError(domain: "Invalid URL", code: 400, userInfo: [NSLocalizedDescriptionKey: "Die URL ist ungültig."])
            print("Fehler: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            let error = NSError(domain: "Unauthorized", code: 401, userInfo: [NSLocalizedDescriptionKey: "Kein JWT-Token gefunden."])
            print("Fehler: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            // JSON-Daten direkt vom DTO erstellen
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted // Optional, für besseres Debugging
            let jsonData = try encoder.encode(voting)

            // Debug: JSON anzeigen
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Gesendete Daten (JSON):\n\(jsonString)")
            }

            request.httpBody = jsonData
        } catch {
            print("Fehler beim Kodieren der JSON-Daten: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Netzwerkfehler: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "Invalid Response", code: 500, userInfo: [NSLocalizedDescriptionKey: "Ungültige Serverantwort."])
                print("Fehler: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            print("HTTP-Statuscode: \(httpResponse.statusCode)")
            if !(200...299).contains(httpResponse.statusCode) {
                if let data = data, let responseText = String(data: data, encoding: .utf8) {
                    print("Serverantwort:\n\(responseText)")
                }
                let error = NSError(domain: "Server Error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Serverfehler mit Statuscode: \(httpResponse.statusCode)"])
                completion(.failure(error))
                return
            }

            guard let data = data else {
                let error = NSError(domain: "No Data", code: 204, userInfo: [NSLocalizedDescriptionKey: "Keine Daten erhalten."])
                print("Fehler: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .useDefaultKeys // Verwende Standard-Decoding
                let createdVoting = try decoder.decode(GetVotingDTO.self, from: data)

                print("Erfolgreich erstellt:\n\(createdVoting)")
                completion(.success(createdVoting))
            } catch {
                print("Fehler beim Dekodieren der Antwort: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    func openVoting(votingId: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/votings/\(votingId)/open") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(NSError(domain: "Unauthorized", code: 401, userInfo: nil)))
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "Server Error", code: 500, userInfo: nil)))
                return
            }
            
            completion(.success(()))
        }.resume()
    }
    
    func fetchVoting(byId votingId: UUID, completion: @escaping (Result<GetVotingDTO, Error>) -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/votings/\(votingId)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 500, userInfo: nil)))
                return
            }

            // Debugging: API-Antwort prüfen
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP-Status: \(httpResponse.statusCode)")
            }
            if let responseText = String(data: data, encoding: .utf8) {
                print("Antwort: \(responseText)")
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let voting = try decoder.decode(GetVotingDTO.self, from: data)
                completion(.success(voting))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }





    

}
