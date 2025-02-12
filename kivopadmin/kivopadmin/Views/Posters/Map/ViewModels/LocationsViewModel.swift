// This file is licensed under the MIT-0 License.

import PosterServiceDTOs
import SwiftUI
import MapKit

class LocationsViewModel: ObservableObject {
    @Published var uiImage: Data? = nil
    @Published var selectedUserNames: [String] = []
    @Published var isEditing = false
    @Published var isLoading: Bool = false
    @Published var satelliteView: Bool = false
    @Published var summary: PosterSummaryResponseDTO? = nil
    @Published var errorMessage: String? = nil
    @Published var showLocationsList: Bool = false
    @Published var sheetPosition: PosterPositionWithAddress? = nil
    @Published var selectedPosterPosition: PosterPositionWithAddress? // Aktuell ausgewählte Position
    @Published var selectedFilter: PosterPositionStatus? = nil {
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
            self?.posterPositionsWithAddresses = positionsWithAddresses
            self?.fetchImagesForPositions() // Hier Bilder abrufen!
            print("Alle Adressen wurden erfolgreich generiert und sortiert.")
        }

    }
    func fetchImagesForPositions() {
        let dispatchGroup = DispatchGroup()

        for (index, position) in posterPositionsWithAddresses.enumerated() {
            dispatchGroup.enter()
            fetchPosterPositionImage(posterPositionId: position.position.id) { imageData in
                DispatchQueue.main.async {
                    if let imageData = imageData {
                        self.posterPositionsWithAddresses[index] = PosterPositionWithAddress(
                            position: position.position,
                            address: position.address,
                            image: imageData
                        )
                    }
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            print("Alle Bilder wurden erfolgreich geladen.")
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
    func fetchPosterPositionImage(posterPositionId: UUID, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/posters/positions/\(posterPositionId)/image") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let data = data, error == nil {
                    completion(data)
                } else {
                    completion(nil)
                }
            }
        }.resume()
    }


    
    func fetchPosterSummary(poster: PosterResponseDTO) {
        guard let url = URL(string: "https://kivop.ipv64.net/posters/\(poster.id)/summary") else {
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
                    self?.summary = try decoder.decode(PosterSummaryResponseDTO.self, from: data)

                    
                } catch {
                    self?.errorMessage = "Failed to decode positions: \(error.localizedDescription)"
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }

    func createPosterPosition(posterPosition: CreatePosterPositionDTO, posterId: UUID) {
        guard let url = URL(string: "https://kivop.ipv64.net/posters/\(posterId)/positions") else {
            self.errorMessage = "Invalid URL."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Authentifizierung hinzufügen
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            self.errorMessage = "Unauthorized: Token not found."
            return
        }

        // JSON-Daten in den Body der Anfrage schreiben
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 // Sicherstellen, dass das Datum im richtigen Format kodiert wird

        do {
            let jsonData = try encoder.encode(posterPosition)
            request.httpBody = jsonData

            // JSON-Daten loggen
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("JSON Payload: \(jsonString)")
            }
        } catch {
            self.errorMessage = "Failed to encode poster position: \(error.localizedDescription)"
            return
        }

        isLoading = true

        // Netzwerkaufruf starten
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage = "Unexpected response format."
                    return
                }

                if !(200...299).contains(httpResponse.statusCode) {
                    self?.errorMessage = "Server error: \(httpResponse.statusCode) - \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                    if let data = data, let responseText = String(data: data, encoding: .utf8) {
                        print("Server Response: \(responseText)")
                    }
                    return
                }

                // Erfolg: Daten verarbeiten
                if let data = data {
                    print("Success: \(String(data: data, encoding: .utf8) ?? "No response data")")
                }

                self?.errorMessage = nil // Erfolgreich
            }
        }.resume()
        

    }
    func patchPosterPosition(posterPositionId: UUID, posterPosition: CreatePosterPositionDTO, posterId: UUID) {
        guard let url = URL(string: "https://kivop.ipv64.net/posters/\(posterId)/positions/\(posterPositionId)") else {
            self.errorMessage = "Invalid URL."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Authentifizierung hinzufügen
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            self.errorMessage = "Unauthorized: Token not found."
            return
        }

        // JSON-Daten in den Body der Anfrage schreiben
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 // Sicherstellen, dass das Datum im richtigen Format kodiert wird

        do {
            let jsonData = try encoder.encode(posterPosition)
            request.httpBody = jsonData

            // JSON-Daten loggen
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("JSON Payload: \(jsonString)")
            }
        } catch {
            self.errorMessage = "Failed to encode poster position: \(error.localizedDescription)"
            return
        }

        isLoading = true

        // Netzwerkaufruf starten
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage = "Unexpected response format."
                    return
                }

                if !(200...299).contains(httpResponse.statusCode) {
                    self?.errorMessage = "Server error: \(httpResponse.statusCode) - \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                    if let data = data, let responseText = String(data: data, encoding: .utf8) {
                        print("Server Response: \(responseText)")
                    }
                    return
                }

                // Erfolg: Daten verarbeiten
                if let data = data {
                    print("Success: \(String(data: data, encoding: .utf8) ?? "No response data")")
                }

                self?.errorMessage = nil // Erfolgreich
            }
        }.resume()
        

    }
    
    func deleteSignlePosterPosition(positionId: UUID, completion: @escaping () -> Void) {
        guard let url = URL(string: "https://kivop.ipv64.net/posters/positions/\(positionId)") else {
            self.errorMessage = "Invalid URL."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            self.errorMessage = "Unauthorized: Token not found."
            return
        }

        isLoading = true

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    self?.errorMessage = "Server error or unexpected response."
                    return
                }

                // Erfolgsfall: Completion aufrufen
                completion()
            }
        }.resume()
    }
}
