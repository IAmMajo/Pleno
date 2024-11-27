import Foundation
import MeetingServiceDTOs

struct VotingAPI {
    static let baseURL = "https://kivop.ipv64.net/meetings"

    // MARK: - Alle Umfragen abfragen
    static func fetchAllVotings(completion: @escaping (Result<[GetVotingDTO], Error>) -> Void) {
        let urlString = "\(baseURL)/votings"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 500, userInfo: nil)))
                return
            }

            // Debug-Ausgabe der Rohdaten
            if let jsonString = String(data: data, encoding: .utf8) {
                print("API Response JSON: \(jsonString)")
            } else {
                print("Fehler: Keine JSON-Daten decodiert")
            }

            do {
                let decodedVotings = try JSONDecoder().decode([GetVotingDTO].self, from: data)
                completion(.success(decodedVotings))
            } catch {
                // Fehlerdetails beim Decoding ausgeben
                print("Decoding-Fehler: \(error.localizedDescription)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Fehlerhafte JSON-Daten: \(jsonString)")
                }
                completion(.failure(error))
            }
        }
        task.resume()
    }



    // MARK: - Umfrage erstellen
    static func createVoting(voting: CreateVotingDTO, completion: @escaping (Result<GetVotingDTO, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/votings") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(voting)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            do {
                let createdVoting = try JSONDecoder().decode(GetVotingDTO.self, from: data)
                completion(.success(createdVoting))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }

    // MARK: - Umfrage updaten
    static func updateVoting(id: UUID, voting: PatchVotingDTO, completion: @escaping (Result<GetVotingDTO, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/votings/\(id)") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(voting)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            do {
                let updatedVoting = try JSONDecoder().decode(GetVotingDTO.self, from: data)
                completion(.success(updatedVoting))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
    
    // MARK: - Close Voting
        static func closeVoting(votingId: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
            let urlString = "\(baseURL)/\(votingId)/close"
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            // Hier ggf. Authentifizierungstoken hinzufügen, falls erforderlich
            // request.addValue("Bearer <TOKEN>", forHTTPHeaderField: "Authorization")

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
                    let error = NSError(domain: "API Error", code: statusCode, userInfo: nil)
                    completion(.failure(error))
                    return
                }

                completion(.success(()))
            }
            task.resume()
        }

    // MARK: - Umfrage löschen
    static func deleteVoting(id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/votings/\(id)") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
                completion(.failure(APIError.invalidResponse))
                return
            }

            completion(.success(()))
        }

        task.resume()
    }

    // MARK: - Ergebnisse einer Umfrage abrufen
    static func fetchVotingResults(id: UUID, completion: @escaping (Result<GetVotingResultsDTO, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/votings/\(id)/results") else {
            completion(.failure(APIError.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            do {
                let results = try JSONDecoder().decode(GetVotingResultsDTO.self, from: data)
                completion(.success(results))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }

    // MARK: - Fehlerdefinition
    enum APIError: Error, LocalizedError {
        case invalidURL
        case noData
        case invalidResponse

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Ungültige URL."
            case .noData:
                return "Keine Daten erhalten."
            case .invalidResponse:
                return "Ungültige Antwort vom Server."
            }
        }
    }
}
