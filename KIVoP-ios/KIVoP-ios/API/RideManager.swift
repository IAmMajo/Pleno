import Foundation
import RideServiceDTOs

class RideManager: ObservableObject {
    static let shared = RideManager()
    var eventRides: [GetEventRideDTO] = []
    private let baseURL = "https://kivop.ipv64.net"
    
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
    func fetchRideDetails(for rideID: UUID) async throws -> GetSpecialRideDetailDTO {
        guard let url = URL(string: "https://kivop.ipv64.net/specialrides/\(rideID)") else {
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
        guard let url = URL(string: "https://kivop.ipv64.net/specialrides/\(rideID)") else {
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
    func requestSpecialRide(rideID: UUID, latitude: Float, longitude: Float) async throws -> GetRiderDTO {
        guard let url = URL(string: "https://kivop.ipv64.net/specialrides/\(rideID)/requests") else {
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
        guard let url = URL(string: "https://kivop.ipv64.net/specialrides/requests/\(riderID)") else {
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
    func removeFromSpecialPassengers(riderID: UUID, longitude: Float, latitude: Float) async throws -> GetRiderDTO {
        guard let url = URL(string: "https://kivop.ipv64.net/specialrides/requests/\(riderID)") else {
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
    
    // Funktion zum Abrufen der EventRides
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
                    print("Ride Manger: \(self?.eventRides)")
                }
            } catch {
                print("JSON Decode Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
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
       let profileImageBaseURL = "https://kivop.ipv64.net/users/profile-image/user"
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
    
    // Date formatieren
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy - HH:mm 'Uhr'"
        return formatter.string(from: date)
    }
}
