//
//  LocationsView.swift
//  kivopadmin
//
//  Created by Adrian on 22.01.25.
//

import SwiftUI
import PosterServiceDTOs
import MapKit


struct LocationsView: View {
    @EnvironmentObject private var locationViewModel: LocationsViewModel
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.6542, longitude: 7.3556),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    var poster: PosterResponseDTO
    
    var body: some View {
        ZStack {
            mapLayer
                .ignoresSafeArea()
            if let selectedPosition = locationViewModel.selectedPosterPosition {
                VStack {
                    
                    // Zeige die Adresse oder lade sie asynchron
                    VStack{
                        Button(action: locationViewModel.toggleLocationsList){
                            Text(selectedPosition.address).foregroundColor(.primary).frame(height: 55).frame(maxWidth: .infinity)
                                .overlay(alignment: .leading){
                                    Image(systemName: "arrow.down").font(.headline).foregroundColor(.primary).padding().rotationEffect(Angle(degrees: locationViewModel.showLocationsList ? 180 : 0))
                            }
                        }

                        if locationViewModel.showLocationsList{
                            LocationsListView()
                        }
                        
                    }.background(.thickMaterial).cornerRadius(10).shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 15)
                    .padding()
                        
                    
                    Spacer()
                    
                    ZStack{
                        ForEach(locationViewModel.posterPositionsWithAddresses, id: \.position.id){ position in
                            if locationViewModel.selectedPosterPosition == position {
                                LocationPreviewView(position: position).shadow(color: Color.black.opacity(0.32), radius: 20).padding().transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                            }
                            
                            
                        }
                    }
                }
            }
        }
        .sheet(item: $locationViewModel.sheetPosition, onDismiss: nil) { position in
            LocationDetailView(position: position)
        }
        .onAppear{
            locationViewModel.fetchPosterPositions(poster: poster)
        }
    }
    
    private var mapLayer: some View {
        Map(coordinateRegion: $locationViewModel.mapLocation, annotationItems: locationViewModel.posterPositionsWithAddresses, annotationContent: { position in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: position.position.latitude, longitude: position.position.longitude)){
                LocationMapAnnotationView().scaleEffect(locationViewModel.selectedPosterPosition == position ? 1 : 0.6).shadow(radius: 10)
                    .onTapGesture {
                        locationViewModel.showNextLocation(location: position)
                    }
            }
        })
    }
}
