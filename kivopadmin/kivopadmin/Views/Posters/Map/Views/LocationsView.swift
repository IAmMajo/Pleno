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
    @State private var isSearchActive = false
    @State private var searchText = ""
    @State private var showMenu = false
    private var filterOptions = ["toHang", "hangs", "overdue", "takenDown"]



    var poster: PosterResponseDTO
    let maxWidth: CGFloat = 700
    
    init(poster: PosterResponseDTO) {
        self.poster = poster
    }
    
    var body: some View {
        ZStack {
            mapLayer
                .ignoresSafeArea()
            //if let selectedPosition = locationViewModel.selectedPosterPosition {
                VStack {
                    HStack(alignment: .top){
                        VStack{
                            filterButton
                            if showMenu{
                                filterMenu
                            }
                        }

                        // Zeige die Adresse oder lade sie asynchron
                        VStack{

                            if isSearchActive {  // Wenn die Suche aktiv ist, zeigt das Textfeld an
                                ZStack{
                                    TextField("Suche Adresse", text: $searchText, onCommit: {
                                        performSearch()
                                    })
                                    .padding()
                                    .background(.thickMaterial).cornerRadius(10).shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 15)// Undurchsichtiger Hintergrund
                                    .foregroundColor(.primary)
                                    .padding()
                                    HStack {
                                        Spacer()
                                        Button(action: performSearch) {
                                            Image(systemName: "magnifyingglass")
                                                .padding()
                                        }.padding(.trailing, 20)
                                    }
                                }.frame(maxWidth: maxWidth)

                            } else {
                                VStack{
                                    Button(action: locationViewModel.toggleLocationsList){
                                        Text(locationViewModel.selectedPosterPosition?.address ?? "Wählen Sie eine Position aus").foregroundColor(.primary).frame(height: 55).frame(maxWidth: .infinity)
                                            .overlay(alignment: .leading){
                                                Image(systemName: "arrow.down").font(.headline).foregroundColor(.primary).padding().rotationEffect(Angle(degrees: locationViewModel.showLocationsList ? 180 : 0))
                                        }
                                    }

                                    if locationViewModel.showLocationsList{
                                        LocationsListView()
                                    }

                                    
                                }.background(.thickMaterial).cornerRadius(10).shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 15)
                                .padding()
                                .frame(maxWidth: maxWidth)
                            }
                        }

                        searchButton
                    }

                        
                    
                    Spacer()
                    

                    HStack{
                        ForEach(locationViewModel.posterPositionsWithAddresses, id: \.position.id){ position in
                            if locationViewModel.selectedPosterPosition == position {
                                LocationPreviewView(position: position)
                                    .shadow(color: Color.black.opacity(0.32), radius: 20)
                                    .padding()
                                    .frame(maxWidth: maxWidth)
                                    .frame(maxWidth: .infinity)
                                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                            }
                            
                            
                        }
                        
                    }

                    
                }
            //}
        }
        .sheet(item: $locationViewModel.sheetPosition, onDismiss: nil) { position in
            LocationDetailView(position: position)
        }
        .onAppear{
            locationViewModel.fetchPosterPositions(poster: poster)
        }
    }
    
    private var mapLayer: some View {
        Map(coordinateRegion: $locationViewModel.mapLocation, annotationItems: locationViewModel.filteredPositions, annotationContent: { position in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: position.position.latitude, longitude: position.position.longitude)){
                LocationMapAnnotationView(position: position).scaleEffect(locationViewModel.selectedPosterPosition == position ? 1 : 0.6).shadow(radius: 10)
                    .onTapGesture {
                        locationViewModel.showNextLocation(location: position)
                    }
            }
        })
    }
    
    private var searchButton: some View {
        Button {
            withAnimation {
                locationViewModel.showLocationsList = false
                isSearchActive.toggle()
                
            }
        } label: {
            if isSearchActive {
                Image(systemName: "list.bullet").font(.headline).padding(16).foregroundColor(.primary).background(.thickMaterial).cornerRadius(10).shadow(radius: 4).padding()
            } else {
                Image(systemName: "magnifyingglass").font(.headline).padding(16).foregroundColor(.primary).background(.thickMaterial).cornerRadius(10).shadow(radius: 4).padding()
            }
            
        }
    }
    private var filterButton: some View {
        Button {
            withAnimation {
                showMenu.toggle()  // Sichtbarkeit des Menüs umschalten
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle").font(.headline).padding(16).foregroundColor(.primary).background(.thickMaterial).cornerRadius(10).shadow(radius: 4).padding()
        }
    }
    private var filterMenu: some View {
        
        VStack(spacing: 20) {
            ForEach(filterOptions, id: \.self) { option in
                ZStack{
                    if option == locationViewModel.selectedFilter{
                        RoundedRectangle(cornerRadius: 8) // Abgerundete Ecken
                            .fill(Color.gray.opacity(0.2)) // Farbe und Transparenz
                            .frame(width: 30, height: 30)
                    }
                    Button(action: {
                        withAnimation {
                            if option == locationViewModel.selectedFilter{
                                locationViewModel.selectedFilter = nil
                            } else {
                                locationViewModel.selectedFilter = option
                            }
                            
                            showMenu = false  // Menü schließen nach Auswahl
                        }
                    }) {
                        let icon = getFilterIcon(for: option)
                        Image(systemName: icon.symbol)
                            .foregroundColor(icon.color)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(.thickMaterial)
        .cornerRadius(10)
        .shadow(radius: 4)
        
    }
    
    func getFilterIcon(for status: String) -> (symbol: String, color: Color) {
        switch status {
        case "toHang":
            return ("xmark.circle", Color(UIColor.secondaryLabel))
        case "hangs":
            return ("photo.on.rectangle.angled", .blue)
        case "overdue":
            return ("exclamationmark.triangle", .red)
        case "takenDown":
            return ("checkmark.circle", .green)
        default:
            return ("questionmark.circle", .gray) // Fallback für unbekannte Status
        }
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
                locationViewModel.mapLocation = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
        }
    }
}

struct tileView: View {
    var title: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.2)) // Farbe der Kachel
                .frame(height: 100) // Höhe der Kachel

            Text(title)
                .font(.headline)
        }
        .shadow(radius: 4) // Optional: Schatten
    }
}
