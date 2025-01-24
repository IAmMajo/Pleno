import PosterServiceDTOs
import SwiftUI
import MapKit

class LocationsViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showLocationsList: Bool = false
    @Published var sheetPosition: PosterPositionWithAddress? = nil
    @Published var selectedPosterPosition: PosterPositionWithAddress? // Aktuell ausgewählte Position
    @Published var selectedFilter: String? = nil {
        didSet {
            applyFilter()
        }
    }

    @Published var posterPositionsWithAddresses: [PosterPositionWithAddress] = [] {
        didSet {
            applyFilter()
        }
    }

    @Published var filteredPositions: [PosterPositionWithAddress] = []

    @Published var mapLocation: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.6542, longitude: 7.3556),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    let mapSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)

    // Initialisierung der Karte mit einem Standardwert
    init() {
        self.mapLocation = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.6542, longitude: 7.3556),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }

    func toggleLocationsList(){
        withAnimation(.easeInOut){
            showLocationsList.toggle()
        }
    }
    func nextButtonPressed(){
        guard let currentIndex = posterPositionsWithAddresses.firstIndex(where: { $0 == selectedPosterPosition }) else {
            return
        }
        
        let nextIndex = currentIndex + 1
        guard filteredPositions.indices.contains(nextIndex) else {
            guard let firstPosition = filteredPositions.first else { return }
            showNextLocation(location: firstPosition)
            return
        }
        
        let nextPosition = filteredPositions[nextIndex]
        showNextLocation(location: nextPosition)
    }
    func showNextLocation(location: PosterPositionWithAddress){
        withAnimation(.easeInOut){
            mapLocation = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: location.position.latitude, longitude: location.position.longitude),
                span: mapSpan
            )
            selectedPosterPosition = location
            showLocationsList = false
        }
    }
    
    func updateMapLocation(location: PosterPositionWithAddress) {
        withAnimation(.easeInOut) {
            mapLocation = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: location.position.latitude, longitude: location.position.longitude),
                span: mapSpan
            )
            selectedPosterPosition = location // Aktuelle Position setzen
        }
    }

    func selectPosterPosition(at index: Int) {
        // Sicherstellen, dass der Index gültig ist
        guard index >= 0 && index < filteredPositions.count else {
            errorMessage = "Ungültiger Index."
            return
        }
        let selectedPosition = filteredPositions[index]
        updateMapLocation(location: selectedPosition) // Karte und Auswahl aktualisieren
    }

    
    private func applyFilter() {
        guard let selectedFilter = selectedFilter else {
            // Wenn kein Filter gesetzt ist, alle Positionen zurückgeben
            filteredPositions = posterPositionsWithAddresses
            return
        }
        // Positionen filtern basierend auf dem Status
        filteredPositions = posterPositionsWithAddresses.filter { $0.position.status == selectedFilter }
    }


    func getAddressFromCoordinates(latitude: Double, longitude: Double, completion: @escaping (String?) -> Void) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
       
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                completion(nil)
            } else if let placemark = placemarks?.first {
                let address = [
                    placemark.name,
                    placemark.locality,
                ].compactMap { $0 }.joined(separator: ", ")
                completion(address)
            } else {
                completion(nil)
            }
        }
    }

    private func generateAddresses(for positions: [PosterPositionResponseDTO]) {
        var positionsWithAddresses: [PosterPositionWithAddress] = []
        let dispatchGroup = DispatchGroup() // Für Synchronisierung mehrerer Anfragen
        
        for position in positions {
            dispatchGroup.enter()
            
            getAddressFromCoordinates(latitude: position.latitude, longitude: position.longitude) { [weak self] address in
                DispatchQueue.main.async {
                    if let address = address {
                        let positionWithAddress = PosterPositionWithAddress(position: position, address: address)
                        positionsWithAddresses.append(positionWithAddress)
                    } else {
                        let fallbackAddress = "Adresse nicht verfügbar"
                        let positionWithAddress = PosterPositionWithAddress(position: position, address: fallbackAddress)
                        positionsWithAddresses.append(positionWithAddress)
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            // Sortiere die Liste nach dem Status der Positionen
            let statusOrder = ["toHang", "hangs", "overdue", "takenDown"]
            positionsWithAddresses.sort { lhs, rhs in
                let lhsIndex = statusOrder.firstIndex(of: lhs.position.status.lowercased()) ?? Int.max
                let rhsIndex = statusOrder.firstIndex(of: rhs.position.status.lowercased()) ?? Int.max
                return lhsIndex < rhsIndex
            }
            
            // Die sortierte Liste zuweisen
            self?.posterPositionsWithAddresses = positionsWithAddresses
            print("Alle Adressen wurden erfolgreich generiert und sortiert.")
        }
    }


    func fetchPosterPositions(poster: PosterResponseDTO) {
        guard let url = URL(string: "https://kivop.ipv64.net/posters/\(poster.id)/positions") else {
            errorMessage = "Invalid URL."
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            errorMessage = "Unauthorized: Token not found."
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                do {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = "Network error: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                        self?.errorMessage = "Invalid server response."
                        return
                    }
                    
                    guard let data = data else {
                        self?.errorMessage = "No data received."
                        return
                    }
                    
                    // Decode the positions
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let positions = try decoder.decode([PosterPositionResponseDTO].self, from: data)

                    
                    self?.generateAddresses(for: positions) // Adressen generieren
                    
                } catch {
                    self?.errorMessage = "Failed to decode positions: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
}
