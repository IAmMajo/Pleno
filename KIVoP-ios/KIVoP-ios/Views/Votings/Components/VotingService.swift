//
//  VotingService.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 05.01.25.
//

import Foundation
import Combine
import MeetingServiceDTOs

class VotingService: ObservableObject {
    static let shared = VotingService()
    private let baseURL = "https://kivop.ipv64.net/meetings/votings/"
    
   @Published var votings: [GetVotingDTO] = []
   @Published var meetings: [GetMeetingDTO] = []
   
    func fetchVotings(completion: @escaping (Result<[GetVotingDTO], Error>) -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/votings") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)))
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
                decoder.dateDecodingStrategy = .iso8601
                let fetchedVotings = try decoder.decode([GetVotingDTO].self, from: data)
                completion(.success(fetchedVotings))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
   
   func fetchVoting(byId votingId: UUID, completion: @escaping (Result<GetVotingDTO, Error>) -> Void) {
       guard let url = URL(string: "https://kivop.ipv64.net/meetings/votings/\(votingId)") else {
           completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
           return
       }

       var request = URLRequest(url: url)
       request.httpMethod = "GET"
       request.setValue("application/json", forHTTPHeaderField: "Content-Type")

       if let token = UserDefaults.standard.string(forKey: "jwtToken") {
           request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
       } else {
           completion(.failure(NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)))
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
               decoder.dateDecodingStrategy = .iso8601
               let voting = try decoder.decode(GetVotingDTO.self, from: data)
               completion(.success(voting))
           } catch {
               completion(.failure(error))
           }
       }.resume()
   }
    
    func fetchVotingResults(votingId: UUID, completion: @escaping (Result<GetVotingResultsDTO, Error>) -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/votings/\(votingId)/results") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)))
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
                decoder.dateDecodingStrategy = .iso8601
                let results = try decoder.decode(GetVotingResultsDTO.self, from: data)
                completion(.success(results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
   
   func castVote(votingID: UUID, index: UInt8, completion: @escaping (Result<Void, Error>) -> Void) {
       // Construct the URL
       let urlString = "https://kivop.ipv64.net/meetings/votings/\(votingID)/vote/\(index)"
       guard let url = URL(string: urlString) else {
           completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
           return
       }

       // Create the URL request
       var request = URLRequest(url: url)
       request.httpMethod = "PUT"
       request.setValue("application/json", forHTTPHeaderField: "Content-Type")
       
       // Add the JWT token
       if let token = UserDefaults.standard.string(forKey: "jwtToken") {
           request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
       } else {
           completion(.failure(NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)))
           return
       }

       // Perform the request
       URLSession.shared.dataTask(with: request) { data, response, error in
           if let error = error {
               completion(.failure(error))
               return
           }

           if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
               completion(.success(())) // Vote was successful
           } else {
               let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
               completion(.failure(NSError(domain: "Unexpected server response", code: statusCode, userInfo: nil)))
           }
       }.resume()
   }
   
   
   //Meeting
   
   func fetchMeeting(byId meetingId: UUID, completion: @escaping (Result<GetMeetingDTO, Error>) -> Void) {
       guard let url = URL(string: "https://kivop.ipv64.net/meetings/\(meetingId)") else {
           completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
           return
       }

       var request = URLRequest(url: url)
       request.httpMethod = "GET"
       request.setValue("application/json", forHTTPHeaderField: "Content-Type")

       if let token = UserDefaults.standard.string(forKey: "jwtToken") {
           request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
       } else {
           completion(.failure(NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)))
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
               decoder.dateDecodingStrategy = .iso8601
               let meeting = try decoder.decode(GetMeetingDTO.self, from: data)
               completion(.success(meeting))
           } catch {
               completion(.failure(error))
           }
       }.resume()
   }
}

extension VotingService {
    func fetchVotings() async throws -> [GetVotingDTO] {
        return try await withCheckedThrowingContinuation { continuation in
            fetchVotings { result in
                switch result {
                case .success(let votings):
                    continuation.resume(returning: votings)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
