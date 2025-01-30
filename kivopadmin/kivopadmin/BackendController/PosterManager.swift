import Combine
import PosterServiceDTOs
import Foundation
import CoreLocation

struct PosterWithSummary {
    var poster: PosterResponseDTO
    var summary: PosterSummaryResponseDTO?
}


class PosterManager: ObservableObject {
    @Published var posterPositions: [PosterPositionResponseDTO] = []
    @Published var posters: [PosterResponseDTO] = []
    @Published var posterPositionsHangs: [PosterPositionResponseDTO] = []
    @Published var posterPositionsToHang: [PosterPositionResponseDTO] = []
    @Published var posterPositionsOverdue: [PosterPositionResponseDTO] = []
    @Published var posterPositionsTakendown: [PosterPositionResponseDTO] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var poster: PosterResponseDTO?

    @Published var posterPosition: PosterPositionResponseDTO?
    @Published var postersWithSummaries: [PosterWithSummary] = []


    func fetchPoster() {
        guard let url = URL(string: "https://kivop.ipv64.net/posters") else {
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
                do{
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
                    
                    // Debug JSON
                    //print(String(data: data, encoding: .utf8) ?? "Invalid JSON")
                    
                    let decoder = JSONDecoder()
                    
                    
                    // Dekodiere die Daten
                    self?.posters = try decoder.decode([PosterResponseDTO].self, from: data)
                    if(self?.posters != nil){
                        print(self?.posters)
                    }
                    


                }catch {
                    self?.errorMessage = "Failed to decode positions: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }


            }
        }.resume()
    }
    

    func fetchPostersAndSummaries() {
        guard let url = URL(string: "https://kivop.ipv64.net/posters") else {
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

                    let decoder = JSONDecoder()
                    let fetchedPosters = try decoder.decode([PosterResponseDTO].self, from: data)
                    
                    // Erstelle die Poster-Array und lade Summaries
                    self?.postersWithSummaries = fetchedPosters.map { PosterWithSummary(poster: $0, summary: nil) }
                    
                    for (index, poster) in fetchedPosters.enumerated() {
                        self?.fetchPosterSummary(poster: poster, index: index)
                    }
                    
                } catch {
                    self?.errorMessage = "Failed to decode posters: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }

    
    func fetchPosterSummary(poster: PosterResponseDTO, index: Int) {
        guard let url = URL(string: "https://kivop.ipv64.net/posters/\(poster.id)/summary") else {
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

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                do {
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
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let summary = try decoder.decode(PosterSummaryResponseDTO.self, from: data)
                    
                    // Summary zum entsprechenden Poster hinzufügen
                    self?.postersWithSummaries[index].summary = summary
                    
                } catch {
                    self?.errorMessage = "Failed to decode summary: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }

    func createPoster(poster: CreatePosterDTO) {
        guard let url = URL(string: "https://kivop.ipv64.net/posters") else {
            errorMessage = "Invalid URL."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Authentifizierung hinzufügen
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            self.errorMessage = "Unauthorized: Token not found."
            return
        }

        // JSON-Body direkt aus dem Poster-Objekt erstellen
        do {
            let jsonData = try JSONEncoder().encode(poster) // Poster als JSON kodieren
            request.httpBody = jsonData
        } catch {
            self.errorMessage = "Failed to encode Poster: \(error.localizedDescription)"
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
    
    func patchPoster(poster: CreatePosterDTO, posterId: UUID) {
        guard let url = URL(string: "https://kivop.ipv64.net/posters/\(posterId)") else {
            errorMessage = "Invalid URL."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Authentifizierung hinzufügen
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            self.errorMessage = "Unauthorized: Token not found."
            return
        }

        // JSON-Body direkt aus dem Poster-Objekt erstellen
        do {
            let jsonData = try JSONEncoder().encode(poster) // Poster als JSON kodieren
            request.httpBody = jsonData
        } catch {
            self.errorMessage = "Failed to encode Poster: \(error.localizedDescription)"
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






    func fetchSinglePoster(poster: PosterResponseDTO) {
        guard let url = URL(string: "https://kivop.ipv64.net/posters/\(poster.id)") else {
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
                do{
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
                    
                    // Debug JSON
                    //print(String(data: data, encoding: .utf8) ?? "Invalid JSON")
                    
                    let decoder = JSONDecoder()
                    
                    
                    // Dekodiere die Daten
                    self?.poster = try decoder.decode(PosterResponseDTO.self, from: data)
                    if(self?.poster != nil){
                        print(self?.poster)
                    }
                    


                }catch {
                    self?.errorMessage = "Failed to decode positions: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }


            }
        }.resume()
    }
    
    func deletePosters(posters: [DeleteDTO], completion: @escaping () -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/posters/batch") else {
            self.errorMessage = "Invalid URL."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
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
        encoder.dateEncodingStrategy = .iso8601 // Datumsformatierung

        do {
            let jsonData = try encoder.encode(posters)
            request.httpBody = jsonData

            // JSON-Daten loggen (optional für Debugging)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("JSON Payload for PATCH: \(jsonString)")
            }
        } catch {
            self.errorMessage = "Failed to encode data: \(error.localizedDescription)"
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

            }
        }.resume()
    }
    
    func deletePoster(posterId: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        // Erstellen der URL mit der Meeting-ID
        guard let url = URL(string: "https://kivop.ipv64.net/posters/\(posterId)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"  // Setze HTTP-Methode auf DELETE
        
        // Füge den Bearer-Token hinzu, wenn vorhanden
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(NSError(domain: "Unauthorized", code: 2, userInfo: nil)))
            return
        }
        
        // Sende die Anfrage
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Fehlerbehandlung
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Überprüfe den Statuscode der Antwort
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                // Erfolgreiches Löschen
                completion(.success(()))
            } else {
                // Fehler beim Löschen
                let error = NSError(domain: "Delete Error", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to delete poster."])
                completion(.failure(error))
            }
        }.resume()
        
        
    }
    
//    func postersSummary() {
//        guard let url = URL(string: "https://kivop.ipv64.net/posters/summary") else {
//            errorMessage = "Invalid URL."
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
//            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        } else {
//            errorMessage = "Unauthorized: Token not found."
//            return
//        }
//
//        isLoading = true
//
//        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            DispatchQueue.main.async {
//                do{
//                    self?.isLoading = false
//                    
//                    if let error = error {
//                        self?.errorMessage = "Network error: \(error.localizedDescription)"
//                        return
//                    }
//                    
//                    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
//                        self?.errorMessage = "Invalid server response."
//                        return
//                    }
//                    
//                    guard let data = data else {
//                        self?.errorMessage = "No data received."
//                        return
//                    }
//                    
//                    
//                    let decoder = JSONDecoder()
//                    
//                    
//                    // Dekodiere die Daten
//                    self?.status = try decoder.decode(PosterSummaryResponseDTO.self, from: data)
//                    
//
//
//                }catch {
//                    self?.errorMessage = "Failed to decode positions: \(error.localizedDescription)"
//                    print("Decoding error: \(error)")
//                }
//
//
//            }
//        }.resume()
//    }

    
    func createPosterPosition(posterPosition: CreatePosterPositionDTO, posterId: UUID) {
        print("Angekommen")
        guard let url = URL(string: "https://kivop.ipv64.net/posters/\(posterId)/positions") else {
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
            let jsonData = try encoder.encode(posterPosition)
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
    
    func fetchPosterPositions(poster: PosterResponseDTO) {
        guard let url = URL(string: "https://kivop.ipv64.net/posters/\(poster.id)/positions") else {
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
                    
                    // Set up the JSONDecoder with dateDecodingStrategy for ISO8601 format
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601  // Add this line to handle ISO 8601 date format
                    
                    // Decode the data into PosterPositionResponseDTO array
                    self?.posterPositions = try decoder.decode([PosterPositionResponseDTO].self, from: data)

                } catch {
                    self?.errorMessage = "Failed to decode positions: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }

    func fetchPosterPositionsHangs(poster: PosterResponseDTO) {
        guard let url = URL(string: "https://kivop.ipv64.net/posters/\(poster.id)/positions?status=hangs") else {
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
                    
                    // Debug JSON
                    // print(String(data: data, encoding: .utf8) ?? "Invalid JSON")
                    
                    let decoder = JSONDecoder()
                    
                    // Passe den Decoder an, um Strings in Zahlen zu konvertieren oder andere Anpassungen vorzunehmen
                    decoder.dateDecodingStrategy = .iso8601 // Beispiel für ISO 8601-Daten
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    // Dekodiere die Daten
                    self?.posterPositionsHangs = try decoder.decode([PosterPositionResponseDTO].self, from: data)
                    
                } catch DecodingError.typeMismatch(let type, let context) {
                    self?.errorMessage = "Type mismatch error: \(type), context: \(context.debugDescription)"
                    print("Type mismatch error: \(type), context: \(context)")
                } catch {
                    self?.errorMessage = "Failed to decode positions: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }

    
    func fetchPosterPositionsToHang(poster: PosterResponseDTO) {
        guard let url = URL(string: "https://kivop.ipv64.net/posters/\(poster.id)/positions?status=tohang") else {
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

                    // Debug JSON
                    // print(String(data: data, encoding: .utf8) ?? "Invalid JSON")

                    let decoder = JSONDecoder()
                    
                    // Passe den Decoder an, um Strings in Double oder andere Typkonflikte zu lösen
                    decoder.dateDecodingStrategy = .iso8601 // Beispiel für ISO-8601-Datumsformat
                    decoder.keyDecodingStrategy = .convertFromSnakeCase

                    // Dekodiere die Daten
                    self?.posterPositionsToHang = try decoder.decode([PosterPositionResponseDTO].self, from: data)
                    
                } catch DecodingError.typeMismatch(let type, let context) {
                    self?.errorMessage = "Type mismatch error: \(type), context: \(context.debugDescription)"
                    print("Type mismatch error: \(type), context: \(context)")
                } catch {
                    self?.errorMessage = "Failed to decode positions: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
    func fetchPosterPositionsOverdue(poster: PosterResponseDTO) {
        guard let url = URL(string: "https://kivop.ipv64.net/posters/\(poster.id)/positions?status=overdue") else {
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

                    // Debug JSON
                    // print(String(data: data, encoding: .utf8) ?? "Invalid JSON")

                    let decoder = JSONDecoder()
                    
                    // Passe den Decoder an, um mögliche Typkonflikte zu lösen
                    decoder.dateDecodingStrategy = .iso8601 // Beispiel: ISO-8601-Datumsformat
                    decoder.keyDecodingStrategy = .convertFromSnakeCase

                    // Dekodiere die Daten
                    self?.posterPositionsOverdue = try decoder.decode([PosterPositionResponseDTO].self, from: data)

                } catch DecodingError.typeMismatch(let type, let context) {
                    self?.errorMessage = "Type mismatch error: \(type), context: \(context.debugDescription)"
                    print("Type mismatch error: \(type), context: \(context)")
                } catch {
                    self?.errorMessage = "Failed to decode positions: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }

    
    func fetchPosterPositionsTakendown(poster: PosterResponseDTO) {
        guard let url = URL(string: "https://kivop.ipv64.net/posters/\(poster.id)/positions?status=takendown") else {
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

                    // Debug JSON
                    // print(String(data: data, encoding: .utf8) ?? "Invalid JSON")

                    let decoder = JSONDecoder()
                    
                    // Passe den Decoder an, um mögliche Typkonflikte zu lösen
                    decoder.dateDecodingStrategy = .iso8601 // Beispiel: ISO-8601-Datumsformat
                    decoder.keyDecodingStrategy = .convertFromSnakeCase

                    // Dekodiere die Daten
                    self?.posterPositionsTakendown = try decoder.decode([PosterPositionResponseDTO].self, from: data)

                } catch DecodingError.typeMismatch(let type, let context) {
                    self?.errorMessage = "Type mismatch error: \(type), context: \(context.debugDescription)"
                    print("Type mismatch error: \(type), context: \(context)")
                } catch {
                    self?.errorMessage = "Failed to decode positions: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }

    func fetchSinglePosterPosition(posterId: UUID, positionId: UUID) {
        guard let url = URL(string: "https://kivop.ipv64.net/posters/\(posterId)/positions/\(positionId)") else {
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

                    // Debug JSON
                    // print(String(data: data, encoding: .utf8) ?? "Invalid JSON")

                    let decoder = JSONDecoder()
                    
                    // Passe den Decoder an, um mögliche Typkonflikte zu lösen
                    decoder.dateDecodingStrategy = .iso8601 // Beispiel: ISO-8601-Datumsformat
                    decoder.keyDecodingStrategy = .convertFromSnakeCase

                    // Dekodiere die Daten
                    self?.posterPosition = try decoder.decode(PosterPositionResponseDTO.self, from: data)

                } catch DecodingError.typeMismatch(let type, let context) {
                    self?.errorMessage = "Type mismatch error: \(type), context: \(context.debugDescription)"
                    print("Type mismatch error: \(type), context: \(context)")
                } catch {
                    self?.errorMessage = "Failed to decode position: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }

    func deleteSignlePosterPosition(posterId: UUID, positionId: UUID, completion: @escaping () -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/posters/\(posterId)/positions/\(positionId)") else {
            self.errorMessage = "Invalid URL."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            self.errorMessage = "Unauthorized: Token not found."
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

                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    self?.errorMessage = "Server error or unexpected response."
                    return
                }

                // Erfolgsfall: Completion aufrufen
                completion()
            }
        }.resume()
    }

    
    func deletePosterPosition(posterId: UUID, positionIds: [UUID], completion: @escaping () -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/posters/\(posterId)/positions/batch") else {
            self.errorMessage = "Invalid URL."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            self.errorMessage = "Unauthorized: Token not found."
            return
        }

        // Erstellen des JSON-Objekts
        let body: [String: Any] = [
            "ids": positionIds.map { $0.uuidString }
        ]
        
        do {
            // Kodieren des JSON-Objekts in den Body
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
        } catch {
            self.errorMessage = "Failed to encode JSON: \(error.localizedDescription)"
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

                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    self?.errorMessage = "Server error or unexpected response."
                    return
                }

                // Erfolgsfall: Completion aufrufen
                completion()
            }
        }.resume()
    }

    

}
