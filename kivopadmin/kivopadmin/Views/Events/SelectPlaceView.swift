import Foundation
import SwiftUI
import MapKit
import PosterServiceDTOs
import AuthServiceDTOs


// Karte, auf der ein Ort ausgewählt werden kann
struct SelectPlaceMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var onRegionChange: (MKCoordinateRegion) -> Void
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: SelectPlaceMapView
        
        init(parent: SelectPlaceMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            parent.onRegionChange(mapView.region)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        let poiFilter = MKPointOfInterestFilter(including: [])
        mapView.pointOfInterestFilter = poiFilter
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
        uiView.removeAnnotations(uiView.annotations)
        
    }
}

struct SelectPlaceView: View {
    @Binding var mapRegion: MKCoordinateRegion
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var locationMapManager = LocationMapManager()
    
    @State private var searchText: String = ""
    
    
    // Array to hold CreatePosterPositionDTO objects
    @State private var posterPositions: [CreatePosterPositionDTO] = []
    
    var body: some View {
        VStack {
            
            
            ZStack {
                SelectPlaceMapView(region: $mapRegion, onRegionChange: { newRegion in
                    mapRegion = newRegion
                })
                .ignoresSafeArea()
                .frame(maxHeight: .infinity)
                VStack {
                    // Suchleiste, um nach Ort zu suchen
                    searchbar
                    HStack {
                        Spacer()
                        // Button um den User zu seinem Standort zu bringen
                        myLocationButton
                    }
                    Spacer()
                }
                VStack {
                    Spacer()
                    // Fadenkreuz zum auswählen der genauen Koordinaten
                    fadenkreuz
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    addLocationButton
                    .padding()
                }
            }
            
        }
    }
    
    private func addLocation() {
        let currentLocation = mapRegion.center
        dismiss()
        
    }
    
    // Funktion für die Suche nach einem Ort
    private func performSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            guard let response = response, error == nil else {
                print("Fehler bei der Suche: \(error?.localizedDescription ?? "Unbekannter Fehler")")
                return
            }
            
            // Wähle das erste Ergebnis aus
            if let firstResult = response.mapItems.first {
                let coordinate = firstResult.placemark.coordinate
                // Karte auf das Suchergebnis einstellen
                mapRegion = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
        }
    }
    
    // Funktion, um den User zu seinem Standort zu bringen
    private func centerOnUserLocation() {
        locationMapManager.requestLocation()
        if let userLocation = locationMapManager.currentLocation {
            mapRegion = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        } else {
            print("Standort nicht verfügbar")
        }
        locationMapManager.stopLocationUpdates()
    }
    
    
}

extension SelectPlaceView{
    private var fadenkreuz: some View {
        ZStack{
            Rectangle()
                .frame(width: 1, height: 30)
                .foregroundColor(.blue)
            Rectangle()
                .frame(width: 30, height: 1)
                .foregroundColor(.blue)
        }
    }
    private var myLocationButton: some View {
        Button(action: centerOnUserLocation) {
            HStack {
                Image(systemName: "location.fill")
                Text("Meine Position")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
    
    private var searchbar: some View {
        ZStack {
            TextField("Adresse suchen", text: $searchText, onCommit: {
                performSearch()
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            HStack {
                Spacer()
                Button(action: performSearch) {
                    Image(systemName: "magnifyingglass")
                        .padding()
                }.padding(.trailing, 20)
            }
        }
    }
    
    private var addLocationButton: some View {
        HStack {
            Spacer()
            Button(action: addLocation) {
                Text("Standort auswählen")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            Spacer()
        }
    }
}
