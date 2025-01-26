import RideServiceDTOs
import SwiftUI
import MapKit

class EventViewModel: ObservableObject {
    @Published var events: [GetEventDTO] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    func fetchEvents() {
        guard let url = URL(string: "https://kivop.ipv64.net/events/") else {
            errorMessage = "Invalid URL."
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            errorMessage = "Unauthorized: Token not found."
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                do {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = "Network error: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                        self?.errorMessage = "Invalid server response."
                        return
                    }
                    
                    guard let data = data else {
                        self?.errorMessage = "No data received."
                        return
                    }
                    
                    // Decode the positions
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    self?.events = try decoder.decode([GetEventDTO].self, from: data)

                    
                } catch {
                    self?.errorMessage = "Failed to decode positions: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
    
    func createEvent(event: CreateEventDTO) {
        guard let url = URL(string: "https://kivop.ipv64.net/events") else {
            self.errorMessage = "Invalid URL."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Authentifizierung hinzufügen
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            self.errorMessage = "Unauthorized: Token not found."
            return
        }

        // JSON-Daten in den Body der Anfrage schreiben
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 // Sicherstellen, dass das Datum im richtigen Format kodiert wird

        do {
            let jsonData = try encoder.encode(event)
            request.httpBody = jsonData

            // JSON-Daten loggen
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("JSON Payload: \(jsonString)")
            }
        } catch {
            self.errorMessage = "Failed to encode poster position: \(error.localizedDescription)"
            return
        }

        isLoading = true

        // Netzwerkaufruf starten
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage = "Unexpected response format."
                    return
                }

                if !(200...299).contains(httpResponse.statusCode) {
                    self?.errorMessage = "Server error: \(httpResponse.statusCode) - \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                    if let data = data, let responseText = String(data: data, encoding: .utf8) {
                        print("Server Response: \(responseText)")
                    }
                    return
                }

                // Erfolg: Daten verarbeiten
                if let data = data {
                    print("Success: \(String(data: data, encoding: .utf8) ?? "No response data")")
                }

                self?.errorMessage = nil // Erfolgreich
            }
        }.resume()
        

    }
}
