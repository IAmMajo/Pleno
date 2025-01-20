import SwiftUI
import MapKit
import PosterServiceDTOs

struct PosterMapView: View {
    @StateObject var posterManager = PosterManager() // PosterManager als StateObject
    var poster: PosterResponseDTO
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.1657, longitude: 10.4515), // Default für Deutschland
        span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0) // Initiale Zoom-Stufe
    )
    
    var body: some View {
        VStack {
            // Hier nutzen wir eine Hilfsfunktion, um PosterPositionResponseDTO als Identifiable zu behandeln
            Map(coordinateRegion: $region, annotationItems: posterManager.posterPositions.map { PosterPositionViewModel(position: $0) }) { position in
                // Pin für jede Position
                MapPin(coordinate: CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude), tint: .red)
            }
            .onAppear {
                posterManager.fetchPosterPositions(poster: poster) // Positionen laden
            }
        }
        .onAppear {
            posterManager.fetchPosterPositions(poster: poster) // Initiales Laden der Positionen
        }
    }
    
    // Funktion zur Aktualisierung der Region auf der Karte, um alle Positionen anzuzeigen
    private func updateRegion(for positions: [PosterPositionResponseDTO]) {
        guard !positions.isEmpty else { return }
        
        let latitudes = positions.map { $0.latitude }
        let longitudes = positions.map { $0.longitude }
        
        let maxLat = latitudes.max() ?? 0
        let minLat = latitudes.min() ?? 0
        let maxLon = longitudes.max() ?? 0
        let minLon = longitudes.min() ?? 0
        
        let centerLat = (maxLat + minLat) / 2
        let centerLon = (maxLon + minLon) / 2
        
        let latitudeDelta = maxLat - minLat
        let longitudeDelta = maxLon - minLon
        
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: latitudeDelta * 1.5, longitudeDelta: longitudeDelta * 1.5)
        )
    }
}

// Hilfsstruktur, die PosterPositionResponseDTO für die Karte als Identifiable darstellt
struct PosterPositionViewModel: Identifiable {
    var id: UUID { UUID() } // Generiert eine eindeutige ID
    var latitude: Double
    var longitude: Double
    
    init(position: PosterPositionResponseDTO) {
        self.latitude = position.latitude
        self.longitude = position.longitude
    }
}
