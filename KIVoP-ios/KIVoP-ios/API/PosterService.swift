//
//  PosterService.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 19.01.25.
//

import Foundation
import Combine
import PosterServiceDTOs

class PosterService: ObservableObject {
    static let shared = PosterService()
    private let baseURL = "https://kivop.ipv64.net/posters"

    @Published var posters: [PosterResponseDTO] = []
    
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
                let decoder = JSONDecoder()
                let positions = try decoder.decode([PosterPositionResponseDTO].self, from: data)
                completion(.success(positions))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
   
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
               let decoder = JSONDecoder()
               let position = try decoder.decode(PosterPositionResponseDTO.self, from: data)
               completion(.success(position))
           } catch {
               completion(.failure(error))
           }
       }.resume()
   }

   func updatePosterPosition(id: UUID, positionId: UUID, dto: UpdatePosterPositionDTO, completion: @escaping (Result<PosterPositionResponseDTO, Error>) -> Void) {
       guard let url = URL(string: "\(baseURL)/\(id)/positions/\(positionId)") else {
           completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
           return
       }

       guard var request = createAuthorizedRequest(url: url, method: "PATCH", contentType: "application/json") else {
           completion(.failure(NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)))
           return
       }

       do {
           let encoder = JSONEncoder()
           request.httpBody = try encoder.encode(dto)
       } catch {
           completion(.failure(error))
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
               let updatedPosition = try decoder.decode(PosterPositionResponseDTO.self, from: data)
               completion(.success(updatedPosition))
           } catch {
               completion(.failure(error))
           }
       }.resume()
   }

    func fetchImage(folder: String, imageURL: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/images/\(folder)/\(imageURL)") else {
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

    func hangPosition(id: UUID, dto: HangPosterPositionDTO, completion: @escaping (Result<HangPosterPositionResponseDTO, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(id)/positions/hang") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        guard var request = createAuthorizedRequest(url: url, method: "PUT", contentType: "multipart/form-data") else {
            completion(.failure(NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)))
            return
        }

        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(dto)
        } catch {
            completion(.failure(error))
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
                let response = try decoder.decode(HangPosterPositionResponseDTO.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func takeDownPosition(id: UUID, dto: TakeDownPosterPositionDTO, completion: @escaping (Result<TakeDownPosterPositionResponseDTO, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(id)/positions/take-down") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }

        guard var request = createAuthorizedRequest(url: url, method: "PUT", contentType: "multipart/form-data") else {
            completion(.failure(NSError(domain: "Unauthorized: Token not found", code: 401, userInfo: nil)))
            return
        }

        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(dto)
        } catch {
            completion(.failure(error))
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
                let response = try decoder.decode(TakeDownPosterPositionResponseDTO.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

extension PosterService {
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
