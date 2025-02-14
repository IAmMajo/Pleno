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

//
//  EventMap.swift
//  KIVoP-ios
//
//  Created by Christian Heller on 26.01.25.
//

import Foundation
import SwiftUI
import MapKit
import PosterServiceDTOs
import AuthServiceDTOs

struct SelectEventLocation: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var onRegionChange: (MKCoordinateRegion) -> Void

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: SelectEventLocation

        init(parent: SelectEventLocation) {
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

struct EventLocationView: View {
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.6542, longitude: 7.3556),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @Binding var selectedLocation: CLLocationCoordinate2D?
    
    @ObservedObject private var locationMapManager = LocationMapManager()
    
    var body: some View {
        VStack {
            ZStack {
                SelectEventLocation(region: $mapRegion, onRegionChange: { newRegion in
                    DispatchQueue.main.async {
                        mapRegion = newRegion
                    }
                })
                .ignoresSafeArea()
                    .frame(maxHeight: .infinity)
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

struct SelectEventLocationView: View {
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.6542, longitude: 7.3556),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    @ObservedObject private var locationMapManager = LocationMapManager()
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedLocation: CLLocationCoordinate2D?
    
    @State private var searchText: String = ""

    var body: some View {

        VStack {
            ZStack {
                SelectEventLocation(region: $mapRegion, onRegionChange: { newRegion in
                    DispatchQueue.main.async {
                        mapRegion = newRegion
                    }
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
