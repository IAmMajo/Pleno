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
extension GetVotingOptionDTO: @retroactive Identifiable {
   public var id: UInt8 {
      self.index
   }
}
extension GetVotingOptionDTO: @retroactive Equatable {}
extension GetVotingOptionDTO: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(votingId)
        hasher.combine(index)
    }

    public static func == (lhs: GetVotingOptionDTO, rhs: GetVotingOptionDTO) -> Bool {
        return lhs.votingId == rhs.votingId && lhs.index == rhs.index
    }
}

extension GetVotingResultDTO: @retroactive Identifiable {
   public var id: UInt8 {
      self.index
   }
}
extension GetVotingResultDTO: @retroactive Equatable {}
extension GetVotingResultDTO: @retroactive Hashable {
   public func hash(into hasher: inout Hasher) {
      hasher.combine(index) // Use `index` as the hashable property
   }
   
   public static func == (lhs: GetVotingResultDTO, rhs: GetVotingResultDTO) -> Bool {
      return lhs.index == rhs.index // Compare instances based on `index`
   }
}

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
   
}
