import Combine
import MeetingServiceDTOs
import Foundation

class LocationManager: ObservableObject {
    @Published var locations: [GetLocationDTO] = [] // Beobachtbare Benutzerliste
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func fetchLocations() {
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

