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
import PosterServiceDTOs
import Foundation
import CoreLocation

// Datenstruktur, die Sammelposten mit der zugehörigen Summary und dem Bild verbindet
struct PosterWithSummary {
    var poster: PosterResponseDTO
    var summary: PosterSummaryResponseDTO?
    var image: Data?
}

// ViewModel für Sammelposten
class PosterManager: ObservableObject {
    // Array mit allen Sammelposten
    @Published var posters: [PosterResponseDTO] = []
    
    // Gibt den Zustand des ViewModels an
    @Published var isLoading: Bool = false
    
    // Potentielle Fehlermeldung
    @Published var errorMessage: String? = nil
    
    // Array mit allen Sammelposten und gehörigen Summaries und Bild
    @Published var postersWithSummaries: [PosterWithSummary] = []
    
    
    // Lädt alle Sammenposten
    func fetchPoster() {
        errorMessage = nil
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
    
    // Lädt alle Sammelposten mit Summaries
    func fetchPostersAndSummaries() {
        errorMessage = nil
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
                    
                    // Initialisiere Poster-Array ohne Summary & Bild
                    self?.postersWithSummaries = fetchedPosters.map { PosterWithSummary(poster: $0, summary: nil, image: nil) }
                    
                    for (index, poster) in fetchedPosters.enumerated() {
                        self?.fetchPosterSummary(poster: poster, index: index)
                        self?.fetchPosterImage(posterId: poster.id) { imageData in
                            DispatchQueue.main.async {
                                self?.postersWithSummaries[index].image = imageData
                            }
                        }
                    }
                    
                } catch {
                    self?.errorMessage = "Failed to decode posters: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
    
    
    // Lädt das Bild zu einem Sammelposten
    func fetchPosterImage(posterId: UUID, completion: @escaping (Data?) -> Void) {
        errorMessage = nil
        guard let url = URL(string: "https://kivop.ipv64.net/posters/\(posterId)/image") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let data = data, error == nil {
                    completion(data)
                } else {
                    completion(nil)
                }
            }
        }.resume()
    }
    func fetchPosterSummary(poster: PosterResponseDTO, index: Int) {
        errorMessage = nil
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
    
    // Erstellt einen Sammelposten
    func createPoster(poster: CreatePosterDTO) {
        errorMessage = nil
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
    
    // Aktualisert einen Sammelposten
    func patchPoster(poster: CreatePosterDTO, posterId: UUID) {
        errorMessage = nil
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
    
    // Löscht einen Sammelposten
    func deletePoster(posterId: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        errorMessage = nil
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
}
