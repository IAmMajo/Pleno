//
//  APIService.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 24.11.24.
//

import Foundation
import MeetingServiceDTOs

extension GetVotingDTO: @retroactive Identifiable {}
extension GetVotingDTO: @retroactive Equatable {}
extension GetVotingDTO: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    public static func == (lhs: GetVotingDTO, rhs: GetVotingDTO) -> Bool {
        return lhs.id == rhs.id
    }
}

extension GetVotingResultDTO: @retroactive Identifiable {
   public var id: UInt8 {
      self.index
   }
}

//enum APIError: Error {
//   case invalidResponse
//   case decodingError
//   case serverError(Int)
//   case unknownError
//}

class APIService {
   static let shared = APIService()
   private let baseURL = "https://kivop.ipv64.net"
   
   private init() {}
   
   
   func sendRequest<T: Decodable>(_ url: URL, method: String = "GET", body: Data? = nil, token: String? = nil, completion: @escaping (Result<T, Error>) -> Void) {
      
      var request = URLRequest(url: url)
      
      request.httpMethod = method
      if let token = token {
         request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      }
      if let body = body {
         request.httpBody = body
         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      }
      
      URLSession.shared.dataTask(with: request) { data, response, error in
         if let error = error {
            completion(.failure(error))
            return
         }
         
         guard let data = data else {
            completion(.failure(NSError(domain: "No Data", code: -1, userInfo: nil)))
            return
         }
         
         do {
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            completion(.success(decodedResponse))
         } catch {
            completion(.failure(error))
         }
         
      }.resume()
   
   }
   
   
   func fetchAllVotings(token: String, completion: @escaping (Result<[GetVotingDTO], Error>) -> Void) {
       let url = URL(string: "https://kivop.ipv64.net/meetings/votings/")!
      APIService.shared.sendRequest(url, token: token, completion: completion)
   }
   
   func fetchVoting(votingId: UUID, token: String, completion: @escaping (Result<GetVotingDTO, Error>) -> Void) {
       let url = URL(string: "https://kivop.ipv64.net/meetings/votings/\(votingId)")!
       APIService.shared.sendRequest(url, token: token, completion: completion)
   }
   
   //    func fetchAllVotings(completion: @escaping (Result<[GetVotingDTO], Error>) -> Void) {
   //        let urlString = "\(baseURL)/meetings/votings"
   //        guard let url = URL(string: urlString) else {
   //            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
   //            return
   //        }
   //
   //        URLSession.shared.dataTask(with: url) { data, response, error in
   //            if let error = error {
   //                completion(.failure(error))
   //                return
   //            }
   //
   //            guard let data = data else {
   //                completion(.failure(NSError(domain: "No Data", code: -1, userInfo: nil)))
   //                return
   //            }
   //
   //            do {
   //                let votings = try JSONDecoder().decode([GetVotingDTO].self, from: data)
   //                completion(.success(votings))
   //            } catch {
   //                completion(.failure(error))
   //            }
   //        }.resume()
   //    }
}
