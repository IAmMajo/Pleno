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

// Neue Struktur für Votings mit den Ergebnissen
public struct CombinedVotingData: Codable {
    public var voting: GetVotingDTO
    public var votingResult: GetVotingResultsDTO
}



// ViewModel für die Abstimmungen
// !! Wird nur innerhalb der MeetingDetailView verwendet, um auf Abstimmungen zu verweisen
class VotingManager: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    @Published var votings: [GetVotingDTO] = []
    @Published var combinedData: [CombinedVotingData] = []

    // Lädt alle Abstimmungen
    func getVotingsMeeting(meetingId: UUID) {
        errorMessage = nil
        guard let url = URL(string: "https://kivop.ipv64.net/meetings/\(meetingId.uuidString)/votings") else {
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
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
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
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Server Response: \(jsonString)")
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let decodedVotings = try decoder.decode([GetVotingDTO].self, from: data)
                DispatchQueue.main.async {
                    self?.votings = decodedVotings
                    // Aufruf zur Funktion, um die Ergebnisse einer Abstimmung zu laden
                    self?.fetchResultsForVotings()
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = "JSON Decode Error: \(error.localizedDescription)"
                }
                print("JSON Decode Error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // Lädt die Ergebnisse zu jeder Abstimmung und speichert sie ab
    private func fetchResultsForVotings() {
        let group = DispatchGroup()
        var combinedResults: [CombinedVotingData] = []

        for voting in votings {
            group.enter()
            
            guard let url = URL(string: "https://kivop.ipv64.net/meetings/votings/\(voting.id)/results") else {
                print("Invalid URL for voting result with ID \(voting.id)")
                group.leave()
                continue
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
                group.leave()
                return
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                defer { group.leave() }
                
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Network error: \(error.localizedDescription)"
                    }
                    print("Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.errorMessage = "No data received for voting result with ID \(voting.id)"
                    }
                    print("No data received for voting result with ID \(voting.id)")
                    return
                }
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do {
                    let votingResult = try decoder.decode(GetVotingResultsDTO.self, from: data)
                    let combined = CombinedVotingData(voting: voting, votingResult: votingResult)
                    combinedResults.append(combined)
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "JSON Decode Error for voting result: \(error.localizedDescription)"
                    }
                    print("JSON Decode Error for voting result: \(error.localizedDescription)")
                }
            }.resume()
        }
        
        group.notify(queue: .main) {
            self.combinedData = combinedResults
            self.errorMessage = nil
            self.isLoading = false
        }
    }
}


