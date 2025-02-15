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
//  VotingService.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 05.01.25.
//

import Foundation
import Combine
import MeetingServiceDTOs

/// A singleton service responsible for handling API calls related to votings and meetings
/// Conforms to `ObservableObject` to allow SwiftUI views to react to state changes
class VotingService: ObservableObject {
   // MARK: - Properties
       
    static let shared = VotingService() /// Shared singleton instance of `VotingService`
    private let baseURL = "https://kivop.ipv64.net/meetings/votings/" /// Base URL for all voting-related API requests
    
   @Published var votings: [GetVotingDTO] = [] /// Holds a list of votings retrieved from the API
   @Published var meetings: [GetMeetingDTO] = [] /// Holds a list of meetings retrieved from the API
   
   // MARK: - Private Helper: Create Authorized Requests
   /// Creates an authorized URL request by adding the JWT token to the headers
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
   
   // MARK: - Votings
   
   /// Fetch all Votings
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
   
   /// Fetch Voting byId
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
    
   // MARK: - Fetch Voting Results
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
   
   //MARK: - Cast Vote
   /// Casts a vote in a specific voting session
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
         // Handle network errors
         if let error = error {
            completion(.failure(error))
            return
         }
         
         // Check the HTTP response status
         guard let httpResponse = response as? HTTPURLResponse else {
            completion(.failure(NSError(domain: "Invalid response", code: 500, userInfo: nil)))
            return
         }
         
         // Parse the response
         if (200...299).contains(httpResponse.statusCode) {
            completion(.success(())) // Vote was successful
         } else {
            // Parse the error message from the server
            if let data = data {
               do {
                  if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                     let reason = json["reason"] as? String {
                     // Include the reason in the error
                     let error = NSError(domain: "Server Error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: reason])
                     completion(.failure(error))
                  } else {
                     // Fallback for unexpected response structure
                     let error = NSError(domain: "Server Error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unexpected server response"])
                     completion(.failure(error))
                  }
               } catch {
                  // JSON parsing error
                  let parseError = NSError(domain: "Server Error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to parse error response"])
                  completion(.failure(parseError))
               }
            } else {
               // No data in response
               let error = NSError(domain: "Server Error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "No error details received"])
               completion(.failure(error))
            }
         }
      }.resume()
   }
   
   // MARK: - Meeting
   /// Fetch Meeting by Id
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

// MARK: - Async Fetching Extension
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
