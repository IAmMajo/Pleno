import Combine
import AuthServiceDTOs
import Foundation

class UserManager: ObservableObject {
    @Published var users: [UserProfileDTO] = [] // Beobachtbare Benutzerliste

    func fetchUsers() {
        // Abrufen der Benutzerprofile (siehe vorherige Implementierung)
        fetchUsers { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedUsers):
                    self?.users = fetchedUsers
                case .failure(let error):
                    print("Fehler beim Abrufen der Benutzer: \(error.localizedDescription)")
                }
            }
        }
    }

    private func fetchUsers(completion: @escaping (Result<[UserProfileDTO], Error>) -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/users") else {
            //completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            //completion(.failure(APIError.unauthorized))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                  let data = data else {
                //completion(.failure(APIError.invalidResponse))
                return
            }

            do {
                let decoder = JSONDecoder()
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                decoder.dateDecodingStrategy = .formatted(formatter)

                let users = try decoder.decode([UserProfileDTO].self, from: data)
                completion(.success(users))
                print(users)
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
