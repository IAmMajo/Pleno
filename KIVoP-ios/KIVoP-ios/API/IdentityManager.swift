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

import Combine
import Foundation
import MeetingServiceDTOs



class IdentityManager: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    @Published var identity: UUID?

    // Eigene Identität des Users laden
    func getMyIdentity() {
        errorMessage = nil
        guard let url = URL(string: "https://kivop.ipv64.net/users/identities") else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
            }
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "Unauthorized: No token found"
            }
            print("Unauthorized: No token found")
            return
        }
        
        // Setze isLoading auf true, um den Start des Ladevorgangs anzuzeigen
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil // Zurücksetzen der Fehlermeldung
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false // Ladevorgang abgeschlossen
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                }
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self?.errorMessage = "No data received from server"
                }
                print("No data received from server")
                return
            }
            
            // Debugging: JSON-String anzeigen
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Server Response: \(jsonString)")
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let decodedIdentity = try decoder.decode([GetIdentityDTO].self, from: data)
                DispatchQueue.main.async {
                    //self?.identity = decodedIdentity.id
                    self?.errorMessage = nil
                    if let id = decodedIdentity.first?.id {
                        print(id)
                        self?.identity = id
                    } else {
                        print("Keine ID gefunden.")
                    }

                }
            } catch {
                print("Fehler beim Dekodieren: \(error)")
                DispatchQueue.main.async {
                    self?.errorMessage = "Fehler beim Dekodieren der Identität"
                }
            }

        }.resume()
    }

   

}
