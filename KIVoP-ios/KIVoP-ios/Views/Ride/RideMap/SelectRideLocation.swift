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

import Foundation
import SwiftUI
import MapKit
import PosterServiceDTOs
import AuthServiceDTOs

// Verarbeitet die Änderungen der beiden Map Views
struct SelectRideLocation: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var onRegionChange: (MKCoordinateRegion) -> Void

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: SelectRideLocation

        init(parent: SelectRideLocation) {
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

// Kleine MapView, die dazu gedacht ist, nur den Standort wiederzuspiegeln, ohne das dieser sich manuell ändern lässt
struct RideLocationView: View {
    // Wenn keine Position übergeben wird, wird Datteln gesetzt
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.6542, longitude: 7.3556),
        span: MKCoordinateSpan(latitudeDelta: 0.007, longitudeDelta: 0.007)
    )
    
    // Wenn sich die selectedLocation im Hauptthread ändert, wird sie sich auch in der Ansicht ändern
    @Binding var selectedLocation: CLLocationCoordinate2D?
    
    @ObservedObject private var locationMapManager = LocationMapManager()
    
    var body: some View {
        VStack {
            ZStack {
                // Map
                SelectRideLocation(region: $mapRegion, onRegionChange: { newRegion in
                    DispatchQueue.main.async {
                        mapRegion = newRegion
                    }
                })
                .disabled(true)
                .ignoresSafeArea()
                .frame(maxHeight: .infinity)
                
                // Markierung des Standorts auf der Map
                Circle()
                    .fill(Color.white)
                    .shadow(radius: 5)
                    .overlay(
                        Image(systemName: "mappin.circle")
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                    )
                    .frame(width: 39, height: 39)
                    .overlay(alignment: .bottom) {
                        IndicatorShape()
                            .fill(Color.white)
                            .frame(width: 20, height: 15)
                            .offset(y: 8)
                    }
                    .offset(y: -(65 / 2))
            }
        }
        .onChange(of: selectedLocation) { oldValue, newValue in
            if let newLocation = newValue {
                // Aktualisieren Sie die Karte mit der neuen Location
                mapRegion.center = newLocation
            }
        }
        .onAppear {
            if let location = selectedLocation {
                mapRegion.center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            }
        }
    }
}

// MapView, die dazu gedacht ist, den Standort selber festlegen zu können
struct SelectRideLocationView: View {
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.6542, longitude: 7.3556),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    @ObservedObject private var locationMapManager = LocationMapManager()
    
    @Environment(\.dismiss) private var dismiss
    
    // Wenn sich die selectedLocation im Hauptthread ändert, wird sie sich auch in der Ansicht ändern
    @Binding var selectedLocation: CLLocationCoordinate2D?
    
    // Für die Sucheingabe
    @State private var searchText: String = ""

    var body: some View {

        VStack {
            ZStack {
                // Map
                SelectRideLocation(region: $mapRegion, onRegionChange: { newRegion in
                    DispatchQueue.main.async {
                        mapRegion = newRegion
                    }
                })
                .ignoresSafeArea()
                    .frame(maxHeight: .infinity)
                VStack {
                    ZStack {
                        // Address Suche
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
                    // Standort des Nutzers
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
                        // Gibt den Standort an die Hauptview zurück
                        Button(action: addLocation) {
                            Text("Standort hinzufügen")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
            .onAppear {
                if let location = selectedLocation {
                    mapRegion.center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                }
            }
        }
    }

    private func addLocation() {
        let selectedLocation = mapRegion.center
        self.selectedLocation = selectedLocation
        dismiss()
    }

    private func zoomToLocation(latitude: Double, longitude: Double) {
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        mapRegion = region
    }

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

