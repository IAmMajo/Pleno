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

//
//  PollAPI.swift
//  kivopadmin
//
//  Created by Amine Ahamri on 19.01.25.
//


import Foundation
import PollServiceDTOs

class PollAPI {
    static let shared = PollAPI()
    private let baseURL = "https://kivop.ipv64.net/polls"

    // MARK: - Fetch All Polls
    func fetchAllPolls(completion: @escaping (Result<[GetPollDTO], Error>) -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/polls") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // JWT-Token aus UserDefaults abrufen
        guard let token = UserDefaults.standard.string(forKey: "jwtToken"), !token.isEmpty else {
            completion(.failure(NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)))
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: 500, userInfo: nil)))
                return
            }

            print("HTTP-Status: \(httpResponse.statusCode)")

            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 500, userInfo: nil)))
                return
            }

            if let responseText = String(data: data, encoding: .utf8) {
                print("Antwort: \(responseText)")
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: nil)))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let polls = try decoder.decode([GetPollDTO].self, from: data)
                completion(.success(polls))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Fetch Poll by ID
    func fetchPollById(pollId: UUID, completion: @escaping (Result<GetPollDTO, Error>) -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/polls/\(pollId)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
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
                let poll = try JSONDecoder().decode(GetPollDTO.self, from: data)
                completion(.success(poll))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func fetchPollResultsById(pollId: UUID, completion: @escaping (Result<GetPollResultsDTO, Error>) -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/polls/\(pollId)/results") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
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
                let results = try JSONDecoder().decode(GetPollResultsDTO.self, from: data)
                completion(.success(results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func createPoll(poll: CreatePollDTO, completion: @escaping (Result<GetPollDTO, Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: [NSLocalizedDescriptionKey: "Die URL ist ungültig."])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            completion(.failure(NSError(domain: "Unauthorized", code: 401, userInfo: [NSLocalizedDescriptionKey: "Kein JWT-Token gefunden."])))
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

            // Konvertiere UInt8 index zu Int, bevor JSON erstellt wird
            let adjustedPoll = CreatePollDTO(
                question: poll.question,
                description: poll.description,
                closedAt: poll.closedAt,
                anonymous: poll.anonymous,
                multiSelect: poll.multiSelect,
                options: poll.options.map { option in
                    GetPollVotingOptionDTO(index: UInt8(option.index), text: option.text)
                }
            )

            let jsonData = try encoder.encode(adjustedPoll)

            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Gesendete JSON-Daten:\n\(jsonString)")
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
                completion(.failure(NSError(domain: "Invalid Response", code: 500, userInfo: [NSLocalizedDescriptionKey: "Ungültige Serverantwort."])))
                return
            }

            print("HTTP-Statuscode: \(httpResponse.statusCode)")

            if !(200...299).contains(httpResponse.statusCode) {
                if let data = data, let serverResponse = String(data: data, encoding: .utf8) {
                    print("Serverantwort:\n\(serverResponse)")
                }
                completion(.failure(NSError(domain: "Server Error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Serverfehler mit Statuscode: \(httpResponse.statusCode)"])))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 204, userInfo: [NSLocalizedDescriptionKey: "Keine Daten erhalten."])))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .useDefaultKeys
                decoder.dateDecodingStrategy = .iso8601

                // Konvertiere index zurück zu UInt8 nach Decodierung
                var createdPoll = try decoder.decode(GetPollDTO.self, from: data)
                createdPoll.options = createdPoll.options.map { option in
                    GetPollVotingOptionDTO(index: UInt8(option.index), text: option.text)
                }

                print("Erfolgreich erstellte Umfrage:\n\(createdPoll)")
                completion(.success(createdPoll))
            } catch {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Fehler beim Dekodieren der Antwort:\n\(responseString)")
                }
                completion(.failure(error))
            }
        }.resume()
    }



    // MARK: - Fetch Poll Results
    func fetchPollResults(byId pollId: UUID, completion: @escaping (Result<GetPollResultsDTO, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(pollId)/results") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(NSError(domain: "Unauthorized", code: 401, userInfo: nil)))
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

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP-Status: \(httpResponse.statusCode)")
            }
            if let responseText = String(data: data, encoding: .utf8) {
                print("Antwort: \(responseText)")
            }

            do {
                let decoder = JSONDecoder()
                let results = try decoder.decode(GetPollResultsDTO.self, from: data)
                completion(.success(results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: - Delete Poll
    func deletePoll(byId pollId: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(pollId)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(NSError(domain: "Unauthorized", code: 401, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid Server Response", code: 0, userInfo: nil)))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "Error", code: httpResponse.statusCode, userInfo: nil)))
                return
            }
            completion(.success(()))
        }.resume()
    }

    // MARK: - Vote in Poll
    func voteInPoll(pollId: UUID, optionIndex: [UInt8], completion: @escaping (Result<GetPollResultsDTO, Error>) -> Void) {
        let optionsString = optionIndex.map { "\($0)" }.joined(separator: ",")
        guard let url = URL(string: "\(baseURL)/\(pollId)/vote/\(optionsString)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(NSError(domain: "Unauthorized", code: 401, userInfo: nil)))
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
                let pollResults = try decoder.decode(GetPollResultsDTO.self, from: data)
                completion(.success(pollResults))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
