import MeetingServiceDTOs
import Combine
import Foundation

class MeetingManager: ObservableObject {
    @Published var meetings: [GetMeetingDTO] = [] // Meetings-Array
    @Published var errorMessage: String? // Fehlernachricht
    @Published var isLoading: Bool = false // Ladeindikator
    
    func fetchAllMeetings() {
        guard let url = URL(string: "https://kivop.ipv64.net/meetings") else {
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

        // Ladeprozess starten
        isLoading = true

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false // Ladeprozess beenden
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

                do {
                    let fetchedMeetings = try JSONDecoder().decode([GetMeetingDTO].self, from: data)
                    self?.meetings = fetchedMeetings // Meetings speichern
                } catch {
                    self?.errorMessage = "Failed to decode meetings: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}


