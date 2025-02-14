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



import PosterServiceDTOs
import SwiftUI
import MapKit

class LocationsViewModel: ObservableObject {
    // Aktuelle Position in der Karte
    @Published var mapCameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 48.137154, longitude: 11.576124),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    // Ausgewählte Benutzer, die für ein Plakat verantwortlich sind
    // Sichtbar beim Hinzufügen einer Position unten rechts
    @Published var selectedUserNames: [String] = []
    
    // Bearbeitungsmodus
    @Published var isEditing = false
    
    // Bool, die angibt, ob die Adresse geladen wird
    @Published var isLoading: Bool = false
    
    // Bool Variable für die Satellitenansicht
    @Published var satelliteView: Bool = false
    
    // Variable für die Summary über einen Sammelposten
    @Published var summary: PosterSummaryResponseDTO? = nil
    
    // Variable für potentielle Fehler bei Fetch Befehlen
    @Published var errorMessage: String? = nil
    
    // Bool, die angibt, ob die Liste ausgeklappt ist
    @Published var showLocationsList: Bool = false
    
    // Bool, die angibt, ob das Sheet für eine Plakatposition geöffnet ist
    @Published var sheetPosition: PosterPositionWithAddress? = nil
    
    // In dieser Variable wird die ausgewählte Plakatposition gespeichert
    @Published var selectedPosterPosition: PosterPositionWithAddress?
    
    // Diese Variable gibt den ausgewählten Filter an
    @Published var selectedFilter: PosterPositionStatus? = nil {
        didSet {
            applyFilter()
        }
    }

    // Variable mit allen Plakatpositionen mit zugehörigen Adressen
    @Published var posterPositionsWithAddresses: [PosterPositionWithAddress] = [] {
        didSet {
            applyFilter()
        }
    }

    // Variable mit allen Plakatpositionen gefiltert nach ausgewähltem Filter
    @Published var filteredPositions: [PosterPositionWithAddress] = []

    // Gibt den Zoom der Karte an
    let mapSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)

    // Initialisierung der Karte mit einem Standardwert
    init() {
        self.mapCameraPosition = .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 51.6542, longitude: 7.3556),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }

    // Liste ausklappen
    func toggleLocationsList(){
        withAnimation(.easeInOut){
            showLocationsList.toggle()
        }
    }
    
    // Wird aufgerufen, wenn der "nächste" Button gedrückt wurde
    func nextButtonPressed(){
        // aktueller Index im Array
        guard let currentIndex = posterPositionsWithAddresses.firstIndex(where: { $0 == selectedPosterPosition }) else {
            return
        }
        
        // nächsten Index auswählen
        let nextIndex = currentIndex + 1
        
        
        guard filteredPositions.indices.contains(nextIndex) else {
            guard let firstPosition = filteredPositions.first else { return }
            // nächste Plakatposition aufrufen
            showNextLocation(location: firstPosition)
            return
        }
        
        // nächste Plakatposition aufrufen
        let nextPosition = filteredPositions[nextIndex]
        showNextLocation(location: nextPosition)
    }
    
    // Funktion, die die nächste Plakatposition aufruft
    func showNextLocation(location: PosterPositionWithAddress){
        withAnimation(.easeInOut){
            // Karte wird auf die neue Position gesetzt
            mapCameraPosition = .region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: location.position.latitude, longitude: location.position.longitude),
                    span: mapSpan
                )
            )
            // die Variable für das ausgewählte Plakat wird aktualisiert
            selectedPosterPosition = location
            
            // Liste wird wieder eingeklappt
            showLocationsList = false
        }
    }
    
    // Funktion, um den Standort der Karte zu aktualsieren
    func updateMapLocation(location: PosterPositionWithAddress) {
        withAnimation(.easeInOut) {
            mapCameraPosition = .region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: location.position.latitude, longitude: location.position.longitude),
                    span: mapSpan
                )
            )
            selectedPosterPosition = location // Aktuelle Position setzen
        }
    }

    // Wählt die nächste Plakatposition aus
    func selectPosterPosition(at index: Int) {
        // Sicherstellen, dass der Index gültig ist
        guard index >= 0 && index < filteredPositions.count else {
            errorMessage = "Ungültiger Index."
            return
        }
        let selectedPosition = filteredPositions[index]
        updateMapLocation(location: selectedPosition) // Karte und Auswahl aktualisieren
    }

    // den gesetzten Filter nach Status anwenden
    private func applyFilter() {
        guard let selectedFilter = selectedFilter else {
            // Wenn kein Filter gesetzt ist, alle Positionen zurückgeben
            filteredPositions = posterPositionsWithAddresses
            return
        }
        // Positionen filtern basierend auf dem Status
        filteredPositions = posterPositionsWithAddresses.filter { $0.position.status == selectedFilter }
    }

    // Koordinaten in Adressen übersetzen
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

    // Funktion, um den Plakatpositionen eine Adresse hinzuzufügen
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
    
    // Funktion, um die Bilder der Plakatpositionen zu laden
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

    // alle Plakatpositionen laden
    func fetchPosterPositions(poster: PosterResponseDTO) {
        errorMessage = nil
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
    
    // Bild einer Plakatposition laden
    func fetchPosterPositionImage(posterPositionId: UUID, completion: @escaping (Data?) -> Void) {
        errorMessage = nil
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


    // Summary über einen Sammelposten laden
    func fetchPosterSummary(poster: PosterResponseDTO) {
        errorMessage = nil
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

    // Plakatposition erstellen
    func createPosterPosition(posterPosition: CreatePosterPositionDTO, posterId: UUID) {
        errorMessage = nil
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
    
    // Plakatposition aktualisieren
    func patchPosterPosition(posterPositionId: UUID, posterPosition: CreatePosterPositionDTO, posterId: UUID) {
        errorMessage = nil
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
    
    // Plakatposition löschen
    func deleteSinglePosterPosition(positionId: UUID, completion: @escaping () -> Void) {
        errorMessage = nil
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
