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



import Combine
import MeetingServiceDTOs
import Foundation

// ViewModel für Orte
class LocationManager: ObservableObject {
    // Array mit verfügbaren Orten aus der Datenbank
    @Published var locations: [GetLocationDTO] = []
    
    // Gibt den Zustand des ViewModels an
    @Published var isLoading: Bool = false
    
    // Potentielle Fehlermeldung
    @Published var errorMessage: String? = nil

    // Lädt alle Orte, die in der Datenbank vorhanden sind
    func fetchLocations() {
        errorMessage = nil
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/locations") else {
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
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage = "Invalid response from server."
                    return
                }

                guard let data = data else {
                    self?.errorMessage = "No data received."
                    return
                }

                let decoder = JSONDecoder()

                // Prüfen, ob der Server eine Fehlermeldung geschickt hat
                if !(200...299).contains(httpResponse.statusCode) {
                    do {
                        let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
                        self?.errorMessage = errorResponse.reason
                        print("Server error: \(errorResponse.reason)")
                    } catch {
                        self?.errorMessage = "Server error: \(httpResponse.statusCode)"
                        print("Failed to decode error response")
                    }
                    return
                }

                // Erfolgreiches Dekodieren der Locations
                do {
                    self?.locations = try decoder.decode([GetLocationDTO].self, from: data)
                    self?.errorMessage = nil // Reset Fehler, falls zuvor einer gesetzt wurde
                } catch {
                    self?.errorMessage = "Failed to decode locations: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }

}

