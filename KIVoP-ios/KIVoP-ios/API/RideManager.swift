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
import CoreLocation
import RideServiceDTOs

class RideManager: ObservableObject {
    static let shared = RideManager()
    var eventRides: [GetEventRideDTO] = []
    private let baseURL = "https://kivop.ipv64.net"
    
    // MARK: - SpecialRideFunktionen
    
    // Funktion zum abrufen der SpecialRides
    func fetchSpecialRides(completion: @escaping ([GetSpecialRideDTO]?) -> Void) {
        // URL for the route GET /specialrides
        guard let url = URL(string: "\(baseURL)/specialrides") else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add JWT token to the headers
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Unauthorized: No token found")
            completion(nil)
            return
        }
        
        // Execute the network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received from server")
                completion(nil)
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                // Decode the response into an array of GetSpecialRideDTO
                let decodedRides = try decoder.decode([GetSpecialRideDTO].self, from: data)
                completion(decodedRides)
            } catch {
                print("JSON Decode Error: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
    
    // Funktion zum Abrufen der Details für SpecialRides
    @MainActor
    func fetchRideDetails(for rideID: UUID) async throws -> GetSpecialRideDetailDTO {
        guard let url = URL(string: "\(baseURL)/specialrides/\(rideID)") else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "Unauthorized: Token not found.", code: 401, userInfo: nil)
        }

        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "Failed to fetch ride details", code: 500, userInfo: nil)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(GetSpecialRideDetailDTO.self, from: data)
    }
    
    // Funktion zum Löschen einer Sonderfahrt
    func deleteSpecialRide(rideID: UUID) async throws {
        guard let url = URL(string: "\(baseURL)/specialrides/\(rideID)") else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"  // HTTP-Methode DELETE für das Löschen

        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "Unauthorized: Token not found.", code: 401, userInfo: nil)
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
            throw NSError(domain: "Failed to delete ride", code: 500, userInfo: nil)
        }
    }
    
    // Funktion zum Anfragen bei einer SonderFahrt
    @MainActor
    func requestSpecialRide(rideID: UUID, latitude: Float, longitude: Float) async throws -> GetRiderDTO {
        guard let url = URL(string: "\(baseURL)/specialrides/\(rideID)/requests") else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"  // HTTP-Methode POST für das Anfordern der Fahrt
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Authorization Header hinzufügen
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "Unauthorized: Token not found.", code: 401, userInfo: nil)
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let requestDTO = CreateSpecialRideRequestDTO(latitude: latitude, longitude: longitude)

        // Konvertiere den Body in JSON
        let jsonData = try JSONEncoder().encode(requestDTO)
        request.httpBody = jsonData

        // Führe die Anfrage aus
        let (data, response) = try await URLSession.shared.data(for: request)

        // Überprüfe die Antwort auf den Statuscode 201 (Created)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw NSError(domain: "Failed to request ride", code: 500, userInfo: nil)
        }

        let decoder = JSONDecoder()
        do {
            // Dekodiere den Rider aus den empfangenen Daten
            let fetchedRider = try decoder.decode(GetRiderDTO.self, from: data)
            return fetchedRider
        } catch {
            throw NSError(domain: "Failed to decode rider", code: 500, userInfo: nil)
        }
    }
    
    // Funktion zum Löschen einer Anfrage bei einer SonderFahrt
    func deleteSpecialRideRequestedSeat(riderID: UUID) async throws {
        guard let url = URL(string: "\(baseURL)/specialrides/requests/\(riderID)") else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"  // HTTP-Methode DELETE für das Löschen der Anfrage

        // Authorization Header hinzufügen
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "Unauthorized: Token not found.", code: 401, userInfo: nil)
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Führe die Anfrage aus
        let (_, response) = try await URLSession.shared.data(for: request)

        // Überprüfe die Antwort auf den Statuscode 204 (No Content)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
            throw NSError(domain: "Failed to delete ride request", code: 500, userInfo: nil)
        }
    }
    
    // Funktion zum Akzeptieren eines angefragten Mitfahrers durch den Fahrer - SpecialRides
    @MainActor
    func acceptRequestedSpecialRider(riderID: UUID, longitude: Float, latitude: Float) async throws -> GetRiderDTO {
        guard let url = URL(string: "https://kivop.ipv64.net/specialrides/requests/\(riderID)") else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"  // HTTP-Methode PATCH für das Akzeptieren des Riders
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Authorization Header hinzufügen
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "Unauthorized: Token not found.", code: 401, userInfo: nil)
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Body für die Anfrage erstellen
        let body: [String: Any] = [
            "longitude": longitude,
            "latitude": latitude,
            "accepted": true
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
        } catch {
            throw NSError(domain: "Failed to create JSON body", code: 500, userInfo: nil)
        }

        // Anfrage ausführen
        let (data, response) = try await URLSession.shared.data(for: request)

        // Überprüfen der Antwort auf Statuscode 200 (OK)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "Failed to accept requested rider", code: 500, userInfo: nil)
        }

        // JSON-Dekodierung und Rückgabe des aktualisierten Riders
        let decoder = JSONDecoder()
        let updatedRider = try decoder.decode(GetRiderDTO.self, from: data)
        return updatedRider
    }
    
    // Funktion zum Ablehnen eines angefragten Mitfahrers durch den Fahrer - SpecialRides
    @MainActor
    func removeFromSpecialPassengers(riderID: UUID, longitude: Float, latitude: Float) async throws -> GetRiderDTO {
        guard let url = URL(string: "\(baseURL)/specialrides/requests/\(riderID)") else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"  // HTTP-Methode PATCH für das Entfernen des Riders
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Authorization Header hinzufügen
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "Unauthorized: Token not found.", code: 401, userInfo: nil)
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Body für die Anfrage erstellen
        let body: [String: Any] = [
            "longitude": longitude,
            "latitude": latitude,
            "accepted": false
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
        } catch {
            throw NSError(domain: "Failed to create JSON body", code: 500, userInfo: nil)
        }

        // Anfrage ausführen
        let (data, response) = try await URLSession.shared.data(for: request)

        // Überprüfen der Antwort auf Statuscode 200 (OK)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "Failed to remove rider from passengers", code: 500, userInfo: nil)
        }

        // JSON-Dekodierung und Rückgabe des aktualisierten Riders
        let decoder = JSONDecoder()
        let updatedRider = try decoder.decode(GetRiderDTO.self, from: data)
        return updatedRider
    }
    
    // MARK: - Event Funktionen
    
    // Funktion zum Abrufen der Events
    func fetchEvents(completion: @escaping ([EventWithAggregatedData]?) -> Void) {
        guard let url = URL(string: "\(baseURL)/events") else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Füge JWT Token zu den Headern hinzu
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Unauthorized: No token found")
            completion(nil)
            return
        }
        
        // Führe den Netzwerkaufruf aus
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received from server")
                completion(nil)
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                // Dekodieren der Antwort in ein Array von GetEventDTO
                let decodedEvents = try decoder.decode([GetEventDTO].self, from: data)
                
                // Hole zuerst die EventRides und speichere sie
                self?.fetchEventRides { _ in
                    guard let self = self else {
                        completion(nil)
                        return
                    }
                    
                    // Jetzt können wir für jedes Event die aggregierten Daten berechnen
                    let eventsWithAggregatedData = decodedEvents.map { event in
                        let aggregatedData = self.aggregatedData(for: event)
                        return EventWithAggregatedData(
                            event: event,
                            allOpenRequests: aggregatedData.allOpenRequests,
                            allAllocatedSeats: aggregatedData.allAllocatedSeats,
                            allEmptySeats: aggregatedData.allEmptySeats,
                            myState: aggregatedData.myState
                        )
                    }
                    completion(eventsWithAggregatedData)  // Rückgabe an das ViewModel
                }
            } catch {
                print("JSON Decode Error: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
    
    // Funktion zum Abrufen aller EventRides zu allen Events
    func fetchEventRides(completion: @escaping ([GetEventRideDTO]?) -> Void) {
        guard let url = URL(string: "\(baseURL)/eventrides") else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        // Prepare the request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Add JWT token to headers
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Unauthorized: No token found")
            completion(nil)
            return
        }
        
        // Perform the network request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received from server")
                completion(nil)
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                // Decode the response into an array of GetEventRideDTO
                let decodedEventRides = try decoder.decode([GetEventRideDTO].self, from: data)
                DispatchQueue.main.async {
                    self?.eventRides = decodedEventRides  // Store the fetched rides
                    completion(decodedEventRides)         // Return the rides to the caller
                }
            } catch {
                print("JSON Decode Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    // MARK: - Event Details
    // Alle Event Rides für ein bestimmtes Event
    @MainActor
    func fetchEventRidesByEvent(eventID: UUID) async throws -> [GetEventRideDTO] {
        guard let url = URL(string: "\(baseURL)/eventrides?byEventID=\(eventID)") else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // Füge JWT-Token zu den Headern hinzu
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "Unauthorized: Token not found.", code: 401, userInfo: nil)
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Führe den Netzwerkaufruf aus
        let (data, response) = try await URLSession.shared.data(for: request)

        // Überprüfe die Antwort auf Statuscode 200 (OK)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "Failed to fetch event rides", code: 500, userInfo: nil)
        }

        // JSON-Dekodierung
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode([GetEventRideDTO].self, from: data)
    }

    // EventDetails abfragen
    @MainActor
    func fetchEventDetails(eventID: UUID) async throws -> GetEventDetailDTO {
        guard let url = URL(string: "\(baseURL)/events/\(eventID)") else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // JWT-Token hinzufügen
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "Unauthorized: Token not found.", code: 401, userInfo: nil)
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Netzwerkaufruf ausführen
        let (data, response) = try await URLSession.shared.data(for: request)

        // Überprüfe die Antwort auf Statuscode 200 (OK)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "Failed to fetch event details", code: 500, userInfo: nil)
        }

        // JSON-Dekodierung
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(GetEventDetailDTO.self, from: data)
    }

    // Teilnahme am Event abfragen
    // Anhand des JWT wird ein Array mit allen EventParticipations vom jeweiligen Nutzer zurückgegeben
    // Wenn es eins gibt was zum Event passt wird dieses zurückgegeben
    // Wenn nicht wird nil returnt
    @MainActor
    func fetchEventParticipation(eventID: UUID) async throws -> GetInterestedPartyDTO? {
        guard let url = URL(string: "\(baseURL)/eventrides/interested") else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // JWT-Token hinzufügen
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "Unauthorized: Token not found.", code: 401, userInfo: nil)
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Netzwerkaufruf ausführen
        let (data, response) = try await URLSession.shared.data(for: request)

        // Überprüfe die Antwort auf Statuscode 200 (OK)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "Failed to fetch participation status", code: 500, userInfo: nil)
        }

        // JSON-Dekodierung
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let interestedList = try decoder.decode([GetInterestedPartyDTO].self, from: data)

        // Rückgabe des passenden Objekts für das Event
        return interestedList.first { $0.eventID == eventID }
    }

    // An einem Event teilnehmen
    // (Wird benötigt um an Eventfahrten teilzunehmen)
    func participateEvent(eventID: UUID) async throws {
        guard let url = URL(string: "\(baseURL)/events/\(eventID)/participations") else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "Unauthorized: Token not found.", code: 401, userInfo: nil)
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let requestBody: [String: Any] = ["participates": true]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw NSError(domain: "Failed to participate in event", code: 500, userInfo: nil)
        }

        // Debugging: Antwort als String ausgeben
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Server Response: \(jsonString)")
        }
    }
    
    // Abholort für ein Event festlegen
    func requestInterestEventRide(eventID: UUID, latitude: Float, longitude: Float) async throws {
        guard let url = URL(string: "\(baseURL)/eventrides/interested") else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "Unauthorized: Token not found.", code: 401, userInfo: nil)
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let requestDTO = CreateInterestedPartyDTO(eventID: eventID, latitude: latitude, longitude: longitude)
        request.httpBody = try JSONEncoder().encode(requestDTO)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw NSError(domain: "Request failed", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: nil)
        }
    }
    
    // Abholort für ein Event bearbeiten
    func patchInterestEventRide(eventID: UUID, latitude: Float, longitude: Float) async throws {
        guard let url = URL(string: "\(baseURL)/eventrides/interested/\(eventID)") else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // JWT-Token hinzufügen
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "Unauthorized: Token not found.", code: 401, userInfo: nil)
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Body-Daten vorbereiten
        let requestDTO = PatchInterestedPartyDTO(latitude: latitude, longitude: longitude)
        do {
            request.httpBody = try JSONEncoder().encode(requestDTO)
        } catch {
            throw NSError(domain: "Error encoding request body", code: 500, userInfo: nil)
        }

        // Netzwerkaufruf ausführen
        let (data, response) = try await URLSession.shared.data(for: request)

        // Überprüfe die Antwort auf Statuscode 200 (OK)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "Failed to patch interest event ride", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: nil)
        }

        // JSON-Dekodierung (optional, falls die Antwort weiterverarbeitet werden soll)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        _ = try decoder.decode(GetInterestedPartyDTO.self, from: data)
    }

    // Abholort für ein Event entfernen
    func deleteInterestEventRide(eventID: UUID) async throws {
        guard let url = URL(string: "\(baseURL)/eventrides/interested/\(eventID)") else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // JWT-Token hinzufügen
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "Unauthorized: Token not found.", code: 401, userInfo: nil)
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Netzwerkaufruf ausführen
        let (_, response) = try await URLSession.shared.data(for: request)

        // Überprüfe die Antwort auf Statuscode 204 (No Content)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
            throw NSError(domain: "Failed to delete interest event ride", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: nil)
        }
    }

    // MARK: - EventRide Funktionalität
    // Details zu einer EventFahrt abfragen
    @MainActor
    func fetchEventRideDetails(eventRideID: UUID) async throws -> GetEventRideDetailDTO {
        // URL mit der eventRide-ID erstellen
        guard let url = URL(string: "\(baseURL)/eventrides/\(eventRideID)") else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // JWT-Token zum Header hinzufügen
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "Unauthorized: Token not found.", code: 401, userInfo: nil)
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Netzwerkaufruf mit async/await
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Überprüfe, ob der Statuscode 200 (OK) vorliegt
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "Failed to fetch ride details", code: 500, userInfo: nil)
        }
        
        // JSON-Dekodierung
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(GetEventRideDetailDTO.self, from: data)
    }
    
    // Fahrt löschen
    func deleteRide(rideID: UUID) async throws {
        // Erstelle die URL mit der rideID
        guard let url = URL(string: "\(baseURL)/eventrides/\(rideID)") else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        // Authorization Header hinzufügen
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Führe den Netzwerkaufruf aus
        let (_, response) = try await URLSession.shared.data(for: request)
        
        // Überprüfe die Antwort auf den Statuscode 204 (No Content)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
            throw NSError(domain: "Failed to delete ride", code: 500, userInfo: nil)
        }
    }
    
    // Nutzer fragt einen Sitzplatz an
    @MainActor
    func requestEventRide(eventRideID: UUID) async throws -> GetRiderDTO {
        // URL mit der eventRide-ID und dem Endpunkt "/requests" erstellen
        guard let url = URL(string: "\(baseURL)/eventrides/\(eventRideID)/requests") else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Authorization Header hinzufügen
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "Unauthorized: Token not found.", code: 401, userInfo: nil)
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Führe den Netzwerkaufruf mit async/await aus
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Überprüfe, ob der Statuscode 201 (Created) vorliegt
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw NSError(domain: "Failed to request ride", code: 500, userInfo: nil)
        }
        
        // JSON-Dekodierung der Antwort in ein GetRiderDTO-Objekt
        let decoder = JSONDecoder()
        return try decoder.decode(GetRiderDTO.self, from: data)
    }

    // Fahrer nimmt einen Mitfahrer an
    @MainActor
    func acceptRequestedRider(riderID: UUID) async throws -> GetRiderDTO {
        // Erstelle die URL anhand der riderID
        guard let url = URL(string: "\(baseURL)/eventrides/requests/\(riderID)") else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"  // HTTP-Methode PATCH verwenden
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Authorization Header hinzufügen
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "Unauthorized: Token not found.", code: 401, userInfo: nil)
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Erstelle den Body für den Request
        let body: [String: Any] = [
            "accepted": true
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            throw NSError(domain: "Error creating JSON body", code: 500, userInfo: nil)
        }
        
        // Führe den Netzwerkaufruf aus
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Überprüfe die Antwort: Statuscode 200 (OK) erwarten
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "Failed to accept requested rider", code: 500, userInfo: nil)
        }
        
        // Dekodiere die Antwort in ein GetRiderDTO-Objekt
        let decoder = JSONDecoder()
        return try decoder.decode(GetRiderDTO.self, from: data)
    }

    // Fahrer entfernt einen Mitfahrer wieder (Dieser bekommt wieder den Status requested)
    @MainActor
    func removeFromPassengers(riderID: UUID) async throws -> GetRiderDTO {
        // Erstelle die URL anhand der riderID
        guard let url = URL(string: "\(baseURL)/eventrides/requests/\(riderID)") else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"  // HTTP-Methode PATCH
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Authorization Header hinzufügen
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "Unauthorized: Token not found.", code: 401, userInfo: nil)
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Request-Body: Setze "accepted" auf false, um den Status zurückzusetzen
        let body: [String: Any] = ["accepted": false]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            throw NSError(domain: "Error creating JSON body", code: 500, userInfo: nil)
        }
        
        // Führe den Netzwerkaufruf aus
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Überprüfe, ob der Statuscode 200 (OK) zurückgegeben wurde
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "Failed to remove rider from passengers", code: 500, userInfo: nil)
        }
        
        // Dekodiere die Antwort in ein GetRiderDTO-Objekt
        let decoder = JSONDecoder()
        return try decoder.decode(GetRiderDTO.self, from: data)
    }
    
    // Mitfahrer gibt seinen Platz wieder frei
    func deleteRideRequestedSeat(riderID: UUID) async throws {
        // Erstelle die URL anhand der riderID
        guard let url = URL(string: "\(baseURL)/eventrides/requests/\(riderID)") else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"  // HTTP-Methode DELETE verwenden
        
        // Authorization Header hinzufügen
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "Unauthorized: Token not found.", code: 401, userInfo: nil)
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Führe den Netzwerkaufruf aus
        let (_, response) = try await URLSession.shared.data(for: request)
        
        // Überprüfe, ob der Statuscode 204 (No Content) vorliegt
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
            throw NSError(domain: "Failed to delete ride request", code: 500, userInfo: nil)
        }
    }
    
    // MARK: - API Calls erstellen und bearbeiten von Fahrten
    // Sonderfahrt erstellen
    @MainActor
    func createSpecialRide(_ specialRideDTO: CreateSpecialRideDTO) async throws -> GetSpecialRideDetailDTO {
        guard let url = URL(string: "\(baseURL)/specialrides") else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Füge JWT-Token hinzu oder wirf Fehler
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "Unauthorized: No token found", code: 401, userInfo: nil)
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        // Setze den Request-Body mit den DTO-Daten
        request.httpBody = try encoder.encode(specialRideDTO)
        
        // Führe den Netzwerkaufruf aus
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Überprüfe die HTTP-Antwort
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw NSError(domain: "Failed to create special ride", code: 500, userInfo: nil)
        }
        
        // JSON-Dekodierung
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(GetSpecialRideDetailDTO.self, from: data)
    }

    // Sonderfahrt bearbeiten
    @MainActor
    func editSpecialRide(_ specialRideDTO: PatchSpecialRideDTO, rideID: UUID) async throws -> GetSpecialRideDetailDTO {
        // Erstelle die URL mit der rideID
        guard let url = URL(string: "\(baseURL)/specialrides/\(rideID)") else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // JWT-Token zum Header hinzufügen
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "Unauthorized: No token found", code: 401, userInfo: nil)
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // JSON-Kodierung des DTO
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(specialRideDTO)

        // Führe die Netzwerkabfrage aus
        let (data, response) = try await URLSession.shared.data(for: request)

        // Überprüfe den HTTP-Statuscode
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "Failed to update ride", code: 500, userInfo: nil)
        }

        // JSON-Dekodierung der Antwort
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(GetSpecialRideDetailDTO.self, from: data)
    }

    // Eventfahrt erstellen
    @MainActor
    func createEventRide(_ eventRideDTO: CreateEventRideDTO) async throws -> GetEventRideDetailDTO {
        // Erstelle die URL für die Event-Fahrt
        guard let url = URL(string: "\(baseURL)/eventrides") else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // JWT-Token hinzufügen oder Fehler werfen
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "Unauthorized: No token found", code: 401, userInfo: nil)
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // JSON-Kodierung des DTO
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(eventRideDTO)

        // Führe die Anfrage aus
        let (data, response) = try await URLSession.shared.data(for: request)

        // Überprüfe den HTTP-Statuscode (201 = Created)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw NSError(domain: "Failed to create event ride", code: 500, userInfo: nil)
        }

        // JSON-Dekodierung der Antwort
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(GetEventRideDetailDTO.self, from: data)
    }

    // Eventfahrt bearbeiten
    @MainActor
    func editEventRide(_ eventRideDTO: PatchEventRideDTO, rideID: UUID) async throws -> GetEventRideDetailDTO {
        // Erstelle die URL für die Event-Fahrt
        guard let url = URL(string: "\(baseURL)/eventrides/\(rideID)") else {
            throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // JWT-Token hinzufügen oder Fehler werfen
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "Unauthorized: No token found", code: 401, userInfo: nil)
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // JSON-Kodierung des DTO
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(eventRideDTO)

        // Führe die Anfrage aus
        let (data, response) = try await URLSession.shared.data(for: request)

        // Überprüfe den HTTP-Statuscode (200 = OK)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "Failed to update event ride", code: 500, userInfo: nil)
        }

        // JSON-Dekodierung der Antwort
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(GetEventRideDetailDTO.self, from: data)
    }
    
    // MARK: - Ride Übersicht
    // Berechnung der aggregierten Daten für ein Event
    // Zeigt an, wie viele freie/belegte Plätze es gibt und ermittelt den höchsten Status des Nutzers
    // Status-Priorität: Fahrer > Mitfahrer (accepted) > Angefragt (requested)
    func aggregatedData(for event: GetEventDTO) -> (myState: UsersRideState, allEmptySeats: UInt8, allAllocatedSeats: UInt8, allOpenRequests: UInt8?) {
        // Filtere die EventRides, die zu diesem Event gehören
        let relevantEventRides = eventRides.filter { $0.eventID == event.id }
        
        // Aggregiere die leeren und belegten Plätze
        let allEmptySeats = relevantEventRides.reduce(0) { $0 + $1.emptySeats }
        let allAllocatedSeats = relevantEventRides.reduce(0) { $0 + $1.allocatedSeats }
        
        // Aggregiere die offenen Anfragen (Optional)
        let allOpenRequests = relevantEventRides.reduce(0) { $0 + ($1.openRequests ?? 0) }
        let allOpenRequestsUInt8: UInt8? = allOpenRequests > 0 ? UInt8(allOpenRequests) : nil
        
        // Bestimme den höchsten Status des Nutzers
        let myState: UsersRideState
        if relevantEventRides.contains(where: { $0.myState == .driver }) {
            myState = .driver
        } else if relevantEventRides.contains(where: { $0.myState == .accepted }) {
            myState = .accepted
        } else if relevantEventRides.contains(where: { $0.myState == .requested }) {
            myState = .requested
        } else {
            myState = .nothing
        }
        return (myState, UInt8(allEmptySeats), UInt8(allAllocatedSeats), allOpenRequestsUInt8)
    }
    
    // MARK: - Berechnung von Adressen
    // Funktion um Adressen zu generieren
    func getAddressFromCoordinates(latitude: Float, longitude: Float, completion: @escaping (String?) -> Void) {
        let clLocation = CLLocation(latitude: Double(latitude), longitude: Double(longitude))
        
        CLGeocoder().reverseGeocodeLocation(clLocation) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let placemark = placemarks?.first else {
                completion(nil)
                return
            }
            
            var addressString = ""
            if let name = placemark.name {
                addressString += name
            }
            if let postalCode = placemark.postalCode {
                addressString += ", \(postalCode)"
            }
            if let city = placemark.locality {
                addressString += " \(city)"
            }
            completion(addressString)
        }
    }
    
    // MARK: - Generelle Ride Funktionen
    // Date formatieren
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy - HH:mm 'Uhr'"
        return formatter.string(from: date)
    }
    
    // MARK: - Profilbilder
    // Authorizierung für die Profilbilder
    private func createAuthorizedRequest(url: URL, method: String, contentType: String = "application/json") -> URLRequest? {
       var request = URLRequest(url: url)
       request.httpMethod = method
       request.setValue(contentType, forHTTPHeaderField: "Content-Type")
       
       if let token = UserDefaults.standard.string(forKey: "jwtToken") {
          request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
       } else {
          return nil
       }
       return request
    }
    
    // Fetch ProfilePictures by Id
    func fetchUserImage(userId: UUID, completion: @escaping (Result<Data, Error>) -> Void) {
       let profileImageBaseURL = "\(baseURL)/users/profile-image/user"
       guard let url = URL(string: "\(profileImageBaseURL)/\(userId.uuidString)") else {
          completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
          return
       }
       
       guard let request = createAuthorizedRequest(url: url, method: "GET") else {
          completion(.failure(NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)))
          return
       }
       
       URLSession.shared.dataTask(with: request) { data, _, error in
          if let error = error {
             completion(.failure(error))
             return
          }
          
          guard let data = data else {
             completion(.failure(NSError(domain: "No data received", code: 500, userInfo: nil)))
             return
          }
          
          completion(.success(data))
       }.resume()
    }
    
    func fetchUserImageAsync(userId: UUID) async throws -> Data {
       try await withCheckedThrowingContinuation { continuation in
          fetchUserImage(userId: userId) { result in
             switch result {
             case .success(let data):
                continuation.resume(returning: data)
             case .failure(let error):
                continuation.resume(throwing: error)
             }
          }
       }
    }
}
