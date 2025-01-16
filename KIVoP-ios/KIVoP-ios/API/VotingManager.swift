import Combine
import Foundation
import MeetingServiceDTOs


public struct CombinedVotingData: Codable {
    public var voting: GetVotingDTO
    public var votingResult: GetVotingResultsDTO
}


// Neue Struktur für Meetings mit zugehörigen Records

class VotingManager: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    @Published var votings: [GetVotingDTO] = []
    @Published var combinedData: [CombinedVotingData] = []

    func getVotingsMeeting(meetingId: UUID) {
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


