import Foundation
import RideServiceDTOs

@MainActor
class RideDetailViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var rideDetail: GetSpecialRideDetailDTO
    private let baseURL = "https://kivop.ipv64.net"
    var ride: GetSpecialRideDTO
    
    init(ride: GetSpecialRideDTO) {
        self.ride = ride
        self.rideDetail = GetSpecialRideDetailDTO(
            id: nil,
            driverName: "",
            isSelfDriver: false,
            name: "",
            description: nil,
            vehicleDescription: nil,
            starts: Date(),
            ends: Date(),
            startLatitude: 0.0,
            startLongitude: 0.0,
            destinationLatitude: 0.0,
            destinationLongitude: 0.0,
            emptySeats: 0,
            riders: []
        )
    }
    
    func fetchRideDetails() {
        Task {
            do {
                self.isLoading = true
                
                guard let rideID = ride.id?.uuidString,
                      let url = URL(string: "https://kivop.ipv64.net/specialrides/\(rideID)") else {
                    throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                
                if let token = UserDefaults.standard.string(forKey: "jwtToken") {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                } else {
                    errorMessage = "Unauthorized: Token not found."
                    self.isLoading = false
                    return
                }
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw NSError(domain: "Failed to fetch ride details", code: 500, userInfo: nil)
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    DispatchQueue.main.async {
                        do {
                            // Dekodiere ein einzelnes Objekt anstelle eines Arrays
                            let fetchedRideDetail = try decoder.decode(GetSpecialRideDetailDTO.self, from: data)
                            self.rideDetail = fetchedRideDetail
                            self.isLoading = false
                        } catch {
                            print("Fehler beim Dekodieren der Ride Details: \(error.localizedDescription)")
                            self.isLoading = false
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }

    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy - HH:mm 'Uhr'"
        return formatter.string(from: date)
    }
}
