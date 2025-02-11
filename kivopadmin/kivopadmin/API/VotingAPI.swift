// This file is licensed under the MIT-0 License.

import Foundation
import MeetingServiceDTOs

// Extension der DTOs
extension GetMeetingDTO: @retroactive @unchecked Sendable {}

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
extension GetVotingDTO: @unchecked @retroactive Sendable {}

extension GetVotingOptionDTO: @retroactive Identifiable {
   public var id: UInt8 {
      self.index
   }
}
extension GetVotingOptionDTO: @retroactive Equatable {}
extension GetVotingOptionDTO: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }

    public static func == (lhs: GetVotingOptionDTO, rhs: GetVotingOptionDTO) -> Bool {
        return lhs.index == rhs.index
    }
}

extension GetVotingResultsDTO: @retroactive @unchecked Sendable {}

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

extension CreateVotingDTO: @retroactive @unchecked Sendable {}

///////////////////////////////////////////////////////

class VotingAPI {
    private let baseURL = "https://kivop.ipv64.net"

    // Singleton instance
    static let shared = VotingAPI()
    private init() {}

   private func performRequest<U: Codable>(
       path: String,
       method: String,
       responseType: U.Type
   ) async throws -> U {
       return try await performRequest(path: path, method: method, body: Optional<EmptyBody>.none, responseType: responseType)
   }

//   private func performRequest<T: Codable, U: Codable>(
//       path: String,
//       method: String,
//       body: T?,
//       responseType: U.Type
//   ) async throws -> U {
//       guard let url = URL(string: baseURL + path) else {
//           throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
//       }
//
//       var request = URLRequest(url: url)
//       request.httpMethod = method
//       request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//       // Add JWT token
//       let token = try await AuthController.shared.getAuthToken()
//       request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//
//       // Encode the body if provided
//       if let body = body {
//           let encoder = JSONEncoder()
//           request.httpBody = try encoder.encode(body)
//       }
//
//       // Perform the network request
//       let (data, response) = try await URLSession.shared.data(for: request)
//       guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//           throw NSError(domain: "Invalid response", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: nil)
//       }
//
//       // Decode the response data
//       let decoder = JSONDecoder()
//       decoder.dateDecodingStrategy = .iso8601
//       return try decoder.decode(responseType, from: data)
//   }
   
   private func performRequest<T: Codable, U>(
       path: String,
       method: String,
       body: T? = nil,
       responseType: U.Type
   ) async throws -> U {
       guard let url = URL(string: baseURL + path) else {
           throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
       }

       var request = URLRequest(url: url)
       request.httpMethod = method
       request.setValue("application/json", forHTTPHeaderField: "Content-Type")

       // Add JWT token
       let token = try await AuthController.shared.getAuthToken()
       request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

       // Encode the body if provided
       if let body = body {
           let encoder = JSONEncoder()
           request.httpBody = try encoder.encode(body)
       }

       // Perform the network request
       let (data, response) = try await URLSession.shared.data(for: request)
       guard let httpResponse = response as? HTTPURLResponse else {
           throw NSError(domain: "Invalid response", code: 500, userInfo: nil)
       }

       // Handle 204 No Content
       if httpResponse.statusCode == 204 {
           if U.self == Void.self {
               return () as! U // Return Void for 204 responses
           } else {
               throw NSError(domain: "Expected a non-empty response", code: 204, userInfo: nil)
           }
       }

       // Ensure status code is OK
       guard httpResponse.statusCode == 200 else {
           throw NSError(domain: "Invalid response", code: httpResponse.statusCode, userInfo: nil)
       }

       // Decode the response if applicable
       if let decodableType = U.self as? Decodable.Type {
           let decoder = JSONDecoder()
           decoder.dateDecodingStrategy = .iso8601
           guard let decodedResponse = try decoder.decode(decodableType, from: data) as? U else {
               throw NSError(domain: "Failed to decode response", code: 500, userInfo: nil)
           }
           return decodedResponse
       }

       throw NSError(domain: "Unexpected Void response decoding attempt", code: 500, userInfo: nil)
   }

   /// A helper struct for when no body is required.
   private struct EmptyBody: Codable {}
   
   
   func fetchAllMeetings() async throws -> [GetMeetingDTO] {
      try await performRequest(path: "/meetings", method: "GET", responseType: [GetMeetingDTO].self)
   }
   
   // Fetch a meeting
   func fetchMeeting(by id: UUID) async throws -> GetMeetingDTO {
      try await performRequest(path: "/meetings/\(id)", method: "GET", responseType: GetMeetingDTO.self)
   }
   
   // begin a meeting
   func beginMeeting(by id: UUID) async throws {
      try await performRequest(path: "/meetings/\(id)/begin", method: "PUT", body: EmptyBody(), responseType: Void.self)
   }
   
   // Fetch all votings
   func fetchAllVotings() async throws -> [GetVotingDTO] {
      try await performRequest(path: "/meetings/votings", method: "GET", responseType: [GetVotingDTO].self)
   }
   
   // Fetch a voting
   func fetchVoting(by id: UUID) async throws -> GetVotingDTO {
      try await performRequest(path: "/meetings/votings/\(id)", method: "GET", responseType: GetVotingDTO.self)
   }
   
   // Fetch voting results
   func fetchVotingResults(by id: UUID) async throws -> GetVotingResultsDTO {
      try await performRequest(path: "/meetings/votings/\(id)/results", method: "GET", responseType: GetVotingResultsDTO.self)
   }
   
   // vote for an option of a voting
   func castVote(of votingId: UUID, with optionIndex: UInt8) async throws {
      try await performRequest(path: "/meetings/votings/\(votingId)/vote/\(optionIndex)", method: "PUT", body: EmptyBody(), responseType: Void.self)
   }
   
//   // Update a voting
//   func updateVoting(id: UUID, with dto: PatchVotingDTO) async throws -> GetVotingDTO {
//      try await performRequest(path: "/meetings/votings/\(id)", method: "PATCH", body: dto, responseType: GetVotingDTO.self)
//   }
   
   // Create a voting
   func createVoting(_ voting: CreateVotingDTO) async throws -> GetVotingDTO {
      try await performRequest(path: "/meetings/votings", method: "POST", body: voting, responseType: GetVotingDTO.self)
   }
   
   // Delete a voting
//   func deleteVoting(id: UUID) async throws {
//      let _ = try await performRequest(path: "/meetings/votings/\(id)", method: "DELETE", responseType: EmptyResponse.self)
//   }
}

// Empty response placeholder
struct EmptyResponse: Codable {}
