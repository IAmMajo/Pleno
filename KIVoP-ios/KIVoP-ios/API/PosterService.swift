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
//  PosterService.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 19.01.25.
//

import Foundation
import Combine
import PosterServiceDTOs

// A service class that manages network requests related to posters
class PosterService: ObservableObject {
   // Singleton instance of `PosterService` to be shared across the app
    static let shared = PosterService()
   // Base URL for poster-related API endpoints
    private let baseURL = "https://kivop.ipv64.net/posters"

   // Published array of posters, automatically updates UI when changed
    @Published var posters: [PosterResponseDTO] = []
    
   // MARK: - Authorization Handling
   /// Creates an authorized `URLRequest` with a JWT token
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
   
   // MARK: - Fetch Posters
   
   /// Fetches all posters
   func fetchPosters(completion: @escaping (Result<[PosterResponseDTO], Error>) -> Void) {
      guard let url = URL(string: baseURL) else {
         completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
         return
      }
      
      guard let request = createAuthorizedRequest(url: url, method: "GET") else {
         completion(.failure(NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)))
         return
      }
      
      URLSession.shared.dataTask(with: request) { data, _, error in
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
            let posters = try decoder.decode([PosterResponseDTO].self, from: data)
            DispatchQueue.main.async {
               self.posters = posters
            }
            completion(.success(posters))
         } catch {
            completion(.failure(error))
         }
      }.resume()
   }
   
   /// Fetches a specific poster by its ID
   func fetchPoster(byId id: UUID, completion: @escaping (Result<PosterResponseDTO, Error>) -> Void) {
      guard let url = URL(string: "\(baseURL)/\(id)") else {
         completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
         return
      }
      
      guard let request = createAuthorizedRequest(url: url, method: "GET") else {
         completion(.failure(NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)))
         return
      }
      
      URLSession.shared.dataTask(with: request) { data, _, error in
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
              let poster = try decoder.decode(PosterResponseDTO.self, from: data)
              completion(.success(poster))
           } catch {
              completion(.failure(error))
           }
        }.resume()
    }
   
   /// Fetches the image associated with a specific poster
   func fetchPosterImage(posterId: UUID) async throws -> Data {
      guard let url = URL(string: "\(baseURL)/\(posterId)/image") else {
         throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
      }
      
      guard let request = createAuthorizedRequest(url: url, method: "GET") else {
         throw NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)
      }
      
      let (data, response) = try await URLSession.shared.data(for: request)
      
      guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
         throw NSError(domain: "Failed to fetch poster image", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: nil)
      }
      
      return data
   }
   
   private func createJSONDecoder() -> JSONDecoder {
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      return decoder
   }
   
   // MARK: - Fetch Poster Positions
       
   /// Fetches all positions for a specific poster
   func fetchPosterPositions(for posterId: UUID, completion: @escaping (Result<[PosterPositionResponseDTO], Error>) -> Void) {
      guard let url = URL(string: "\(baseURL)/\(posterId)/positions") else {
         completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
         return
      }
      
      guard let request = createAuthorizedRequest(url: url, method: "GET") else {
         completion(.failure(NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)))
         return
      }
      
      URLSession.shared.dataTask(with: request) { data, _, error in
         if let error = error {
            completion(.failure(error))
            return
         }
         
         guard let data = data else {
            completion(.failure(NSError(domain: "No data received", code: 500, userInfo: nil)))
            return
         }
         
         do {
            let decoder = self.createJSONDecoder()
            let positions = try decoder.decode([PosterPositionResponseDTO].self, from: data)
            completion(.success(positions))
         } catch {
            completion(.failure(error))
         }
      }.resume()
   }
   
   /// Fetches a specific positions for a specific poster
   func fetchPosterPosition(id: UUID, positionId: UUID, completion: @escaping (Result<PosterPositionResponseDTO, Error>) -> Void) {
      guard let url = URL(string: "\(baseURL)/\(id)/positions/\(positionId)") else {
         completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
         return
      }
      
      guard let request = createAuthorizedRequest(url: url, method: "GET") else {
         completion(.failure(NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)))
         return
      }
      
      URLSession.shared.dataTask(with: request) { data, _, error in
         if let error = error {
            completion(.failure(error))
            return
         }
         
         guard let data = data else {
            completion(.failure(NSError(domain: "No data received", code: 500, userInfo: nil)))
            return
         }
         
         do {
            let decoder = self.createJSONDecoder()
            let position = try decoder.decode(PosterPositionResponseDTO.self, from: data)
            completion(.success(position))
         } catch {
            completion(.failure(error))
         }
      }.resume()
   }
   
   /// Fetches the image associated with a specific position
   func fetchPositionImage(positionId: UUID) async throws -> Data {
      guard let url = URL(string: "\(baseURL)/positions/\(positionId)/image") else {
         throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
      }
      
      guard let request = createAuthorizedRequest(url: url, method: "GET") else {
         throw NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)
      }
      
      let (data, response) = try await URLSession.shared.data(for: request)
      
      guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
         throw NSError(domain: "Failed to fetch position image", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: nil)
      }
      
      return data
   }
   
   // MARK: - Fetch Poster Summary
   
   /// Fetches a summary of all posters
   func fetchPostersSummary() async throws -> PosterSummaryResponseDTO {
      guard let url = URL(string: "\(baseURL)/summary") else {
         throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
      }
      
      guard let request = createAuthorizedRequest(url: url, method: "GET") else {
         throw NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)
      }
      
      let (data, response) = try await URLSession.shared.data(for: request)
      
      guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
         throw NSError(domain: "Failed to fetch posters summary", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: nil)
      }
      
      do {
         let decoder = JSONDecoder()
         decoder.dateDecodingStrategy = .iso8601
         return try decoder.decode(PosterSummaryResponseDTO.self, from: data)
      } catch {
         throw NSError(domain: "Failed to decode posters summary", code: 500, userInfo: nil)
      }
   }
   
   /// Fetches a summary of a specific poster
   func fetchPosterSummary(for posterId: UUID) async throws -> PosterSummaryResponseDTO {
      guard let url = URL(string: "\(baseURL)/\(posterId)/summary") else {
         throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
      }
      
      guard let request = createAuthorizedRequest(url: url, method: "GET") else {
         throw NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)
      }
      
      let (data, response) = try await URLSession.shared.data(for: request)
      
      guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
         throw NSError(domain: "Failed to fetch poster summary", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: nil)
      }
      
      do {
         let decoder = JSONDecoder()
         decoder.dateDecodingStrategy = .iso8601
         return try decoder.decode(PosterSummaryResponseDTO.self, from: data)
      } catch {
         throw NSError(domain: "Failed to decode poster summary", code: 500, userInfo: nil)
      }
   }
   
   // MARK: - Handle Positions (hang, take down, report damage)
   
   // hang a position
   func hangPosition(positionId: UUID, dto: HangPosterPositionDTO) async throws -> HangPosterPositionResponseDTO {
       guard let url = URL(string: "\(baseURL)/positions/\(positionId)/hang") else {
           throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
       }

       guard var request = createAuthorizedRequest(url: url, method: "PUT") else {
           throw NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)
       }

       do {
           request.httpBody = try JSONEncoder().encode(dto)
       } catch {
           throw NSError(domain: "Failed to encode request body", code: 500, userInfo: nil)
       }

       let (data, response) = try await URLSession.shared.data(for: request)
       guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
           throw NSError(domain: "Failed to hang position", code: 500, userInfo: nil)
       }

       do {
           return try JSONDecoder().decode(HangPosterPositionResponseDTO.self, from: data)
       } catch {
           throw NSError(domain: "Failed to decode response", code: 500, userInfo: nil)
       }
   }
   
   //take down a position
   func takeDownPosition(positionId: UUID, dto: TakeDownPosterPositionDTO) async throws -> TakeDownPosterPositionResponseDTO {
       guard let url = URL(string: "\(baseURL)/positions/\(positionId)/take-down") else {
           throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
       }

       guard var request = createAuthorizedRequest(url: url, method: "PUT") else {
           throw NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)
       }

       do {
           request.httpBody = try JSONEncoder().encode(dto)
       } catch {
           throw NSError(domain: "Failed to encode request body", code: 500, userInfo: nil)
       }

       let (data, response) = try await URLSession.shared.data(for: request)
       guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
           throw NSError(domain: "Failed to hang position", code: 500, userInfo: nil)
       }

       do {
           return try JSONDecoder().decode(TakeDownPosterPositionResponseDTO.self, from: data)
       } catch {
           throw NSError(domain: "Failed to decode response", code: 500, userInfo: nil)
       }
   }
   
   // report damaged position
   func reportDamagedPosition(positionId: UUID, dto: ReportDamagedPosterPositionDTO) async throws -> PosterPositionResponseDTO {
      guard let url = URL(string: "\(baseURL)/positions/\(positionId)/report-damage") else {
         throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
      }
      
      guard var request = createAuthorizedRequest(url: url, method: "PUT") else {
         throw NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)
      }
      
      do {
         request.httpBody = try JSONEncoder().encode(dto)
      } catch {
         throw NSError(domain: "Failed to encode request body", code: 500, userInfo: nil)
      }
      
      let (data, response) = try await URLSession.shared.data(for: request)
      
      // Ensure the response is an HTTPURLResponse
      guard let httpResponse = response as? HTTPURLResponse else {
         throw NSError(domain: "Invalid Response", code: 500, userInfo: nil)
      }
      
      // Check the status code
      guard httpResponse.statusCode == 200 else {
         throw NSError(domain: "Failed to report damage", code: httpResponse.statusCode, userInfo: nil)
      }
      
      do {
         return try JSONDecoder().decode(PosterPositionResponseDTO.self, from: data)
      } catch {
         throw NSError(domain: "Failed to decode response", code: 500, userInfo: nil)
      }
   }
   
   // MARK: - Fetch profile image  of logged in user
   func fetchProfileImage(userId: UUID, completion: @escaping (Result<Data, Error>) -> Void) {
      let profileImageBaseURL = "https://kivop.ipv64.net/users/profile-image/user"
      guard let url = URL(string: "\(profileImageBaseURL)/\(userId.uuidString)") else {
         completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
         return
      }
      
      guard let request = createAuthorizedRequest(url: url, method: "GET") else {
         completion(.failure(NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)))
         return
      }
      
      URLSession.shared.dataTask(with: request) { data, _, error in
         if let error = error {
            completion(.failure(error))
            return
         }
         
         guard let data = data else {
            completion(.failure(NSError(domain: "No data received", code: 500, userInfo: nil)))
            return
         }
         
         completion(.success(data))
      }.resume()
   }
   /// fetches profile image asynchronous
   func fetchProfileImageAsync(userId: UUID) async throws -> Data {
      try await withCheckedThrowingContinuation { continuation in
         fetchProfileImage(userId: userId) { result in
            switch result {
            case .success(let data):
               continuation.resume(returning: data)
            case .failure(let error):
               continuation.resume(throwing: error)
            }
         }
      }
   }
}

// MARK: - Extensions for Async/Await Wrappers

extension PosterService {
   func fetchPostersAsync() async throws -> [PosterResponseDTO] {
      try await withCheckedThrowingContinuation { continuation in
         fetchPosters() { result in
            switch result {
            case .success(let poster):
               continuation.resume(returning: poster)
            case .failure(let error):
               continuation.resume(throwing: error)
            }
         }
      }
   }
   
   func fetchPosterAsync(byId posterId: UUID) async throws -> PosterResponseDTO {
      try await withCheckedThrowingContinuation { continuation in
         fetchPoster(byId: posterId) { result in
            switch result {
            case .success(let poster):
               continuation.resume(returning: poster)
            case .failure(let error):
               continuation.resume(throwing: error)
            }
         }
      }
   }
   
   func fetchPosterPositionsAsync(for posterId: UUID) async throws -> [PosterPositionResponseDTO] {
      try await withCheckedThrowingContinuation { continuation in
         fetchPosterPositions(for: posterId) { result in
            switch result {
            case .success(let positions):
               continuation.resume(returning: positions)
            case .failure(let error):
               continuation.resume(throwing: error)
            }
         }
      }
   }
   
   func fetchPosterPositionAsync(id: UUID, positionId: UUID) async throws -> PosterPositionResponseDTO {
      try await withCheckedThrowingContinuation { continuation in
         fetchPosterPosition(id: id, positionId: positionId) { result in
            switch result {
            case .success(let position):
               continuation.resume(returning: position)
            case .failure(let error):
               continuation.resume(throwing: error)
            }
         }
      }
   }
}
