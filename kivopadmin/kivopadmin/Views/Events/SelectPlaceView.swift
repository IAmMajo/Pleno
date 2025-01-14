import Foundation
import SwiftUI
import MapKit
import PosterServiceDTOs
import AuthServiceDTOs



struct SelectPlaceMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var posterPositions: [CreatePosterPositionDTO]
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
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.6542, longitude: 7.3556),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @ObservedObject var userManager = UserManager()
    @ObservedObject private var posterManager = PosterManager()
    @ObservedObject private var locationMapManager = LocationMapManager()
    
    @State private var expiresAt: Date = Date()
    @State private var showUserSelectionSheet = false
    @State private var selectedUsers: [UUID] = []
    @State private var searchText: String = ""

    
    // Array to hold CreatePosterPositionDTO objects
    @State private var posterPositions: [CreatePosterPositionDTO] = []

    var body: some View {

            VStack {

                
                ZStack {
                    SelectPlaceMapView(region: $mapRegion, posterPositions: posterPositions, onRegionChange: { newRegion in
                        mapRegion = newRegion
                    })
                    .ignoresSafeArea()
                        .frame(maxHeight: .infinity)
                    VStack {
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
                        HStack {
                            Spacer()
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
                        Spacer()
                    }
                    VStack {
                        Spacer()
                        ZStack {
                            Rectangle()
                                .frame(width: 1, height: 30)
                                .foregroundColor(.blue)
                            Rectangle()
                                .frame(width: 30, height: 1)
                                .foregroundColor(.blue)
                        }
                        Spacer()
                    }

                    VStack {
                        Spacer()
                        HStack {

                            Spacer()
                            Button(action: addLocation) {
                                Text("Standort hinzufügen")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            Spacer()
                            //Soll auf Ipad vorhanden sein
//                            VStack {
//                                Button(action: zoomIn) {
//                                    Image(systemName: "plus.magnifyingglass")
//                                        .resizable()
//                                        .frame(width: 40, height: 40)
//                                        .foregroundColor(.blue)
//                                        .padding()
//                                        .background(Color.white)
//                                        .clipShape(Circle())
//                                        .shadow(radius: 10)
//                                }
//                                
//                                Button(action: zoomOut) {
//                                    Image(systemName: "minus.magnifyingglass")
//                                        .resizable()
//                                        .frame(width: 40, height: 40)
//                                        .foregroundColor(.blue)
//                                        .padding()
//                                        .background(Color.white)
//                                        .clipShape(Circle())
//                                        .shadow(radius: 10)
//                                }
//                            }
//                            .padding()
                        }
                        .padding()
                    }
                }
            
        }
    }

    private func addLocation() {
        
        let currentLocation = mapRegion.center
        
        // Hier kommt das hin, was du mit dem ausgewählten Ort machen möchtest
        // Create a new CreatePosterPositionDTO object
        let newPosterPosition = CreatePosterPositionDTO(
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude,
            responsibleUsers: selectedUsers,
            expiresAt: expiresAt
        )
        
        
        // Debugging output
        print("Added new poster position: \(newPosterPosition)")
    }

    private func zoomToLocation(latitude: Double, longitude: Double) {
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        mapRegion = region
    }

    // Brauche ich auf dem Ipad
//    private func zoomIn() {
//        let newSpan = MKCoordinateSpan(
//            latitudeDelta: mapRegion.span.latitudeDelta * 0.8,
//            longitudeDelta: mapRegion.span.longitudeDelta * 0.8
//        )
//        mapRegion.span = newSpan
//    }
//    private func zoomOut() {
//        let newSpan = MKCoordinateSpan(
//            latitudeDelta: mapRegion.span.latitudeDelta * 1.2,
//            longitudeDelta: mapRegion.span.longitudeDelta * 1.2
//        )
//        mapRegion.span = newSpan
//    }

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
                mapRegion = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
        }
    }
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




#Preview {
    SelectPlaceView()
}
