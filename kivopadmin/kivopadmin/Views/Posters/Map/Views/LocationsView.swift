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
            Map(coordinateRegion: $locationViewModel.mapLocation).ignoresSafeArea()
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
                }
            }
        }
        .onAppear{
            locationViewModel.fetchPosterPositions(poster: poster)
        }
    }
}
