import Foundation
//import Combine
import RideServiceDTOs

class RideManager: ObservableObject {
    static let shared = RideManager()
    
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
    
    // ProfilePictures by Id
    func fetchUserImage(userId: UUID, completion: @escaping (Result<Data, Error>) -> Void) {
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
    func fetchUserImageAsync(userId: UUID) async throws -> Data {
       try await withCheckedThrowingContinuation { continuation in
          fetchUserImage(userId: userId) { result in
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
