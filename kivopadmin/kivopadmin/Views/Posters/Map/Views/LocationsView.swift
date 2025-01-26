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
    @State private var expiresAt: Date = Date()
    @State private var selectedUsers: [UUID] = []
    @State private var showUserSelectionSheet = false
    private var filterOptions = ["toHang", "hangs", "overdue", "takenDown"]

    @ObservedObject var userManager = UserManager()

    var poster: PosterResponseDTO
    let maxWidth: CGFloat = 700
    
    init(poster: PosterResponseDTO) {
        self.poster = poster
    }
    
    var body: some View {
        ZStack {
            mapLayer
                .ignoresSafeArea()
            if locationViewModel.isEditing{
                editingView
            }
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
                                Button(action: {
                                    locationViewModel.toggleLocationsList()
                                    withAnimation {
                                        locationViewModel.isEditing = false
                                    }
                                }){
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

                    editButton

                    
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
        }
        .sheet(item: $locationViewModel.sheetPosition, onDismiss: nil) { position in
            LocationDetailView(position: position, users: userManager.users, poster: poster)
        }
        .sheet(isPresented: $showUserSelectionSheet) {
            UserSelectionSheet(users: userManager.users, selectedUsers: $selectedUsers)
        }
        .onAppear{
            locationViewModel.fetchPosterPositions(poster: poster)
            userManager.fetchUsers()
        }
    }
    
    private var mapLayer: some View {
        Map(coordinateRegion: $locationViewModel.mapLocation, annotationItems: locationViewModel.filteredPositions, annotationContent: { position in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: position.position.latitude, longitude: position.position.longitude)){
                LocationMapAnnotationView(position: position).scaleEffect(locationViewModel.selectedPosterPosition == position ? 1 : 0.6).shadow(radius: 10)
                    .onTapGesture {
                        withAnimation {
                            locationViewModel.isEditing = false
                        }
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
    private var editButton: some View {
        Button {

            withAnimation {
                locationViewModel.showLocationsList = false
                locationViewModel.selectedPosterPosition = nil
                locationViewModel.isEditing.toggle()  // Sichtbarkeit des Menüs umschalten
                    
            }
            
        } label: {
            if locationViewModel.isEditing {
                Image(systemName: "xmark.circle.fill").font(.headline).padding(16).foregroundColor(.red).background(.thickMaterial).cornerRadius(10).shadow(radius: 4).padding()
            } else {
                Image(systemName: "plus").font(.headline).padding(16).foregroundColor(.primary).background(.thickMaterial).cornerRadius(10).shadow(radius: 4).padding()
            }
            
        }
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
                    span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
                )
            }
        }
    }
    private var editingView: some View {
        ZStack{
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
            VStack{
                Spacer()
                HStack(alignment: .bottom){
                    VStack(alignment: .leading, spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Ablaufdatum")
                                .font(.caption)
                                .foregroundColor(.primary)
                            DatePicker("Datum", selection: $expiresAt, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .cornerRadius(10)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Benutzer auswählen")
                                .font(.caption)
                                .foregroundColor(.primary)
                            Button(action: {
                                showUserSelectionSheet.toggle()
                            }) {
                                Text("Benutzer auswählen")
                                    .font(.headline).frame(width: 200, height: 45)
                            }.buttonStyle(.bordered)
                        }
                        Button(action: addLocation) {
                            Text("Standort hinzufügen")
                                .font(.headline).frame(width: 200, height: 45)
                        }.buttonStyle(.borderedProminent)
                    }
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThickMaterial))
                    .cornerRadius(8)
                    .padding()
                    Spacer()
                }
            }

            if locationViewModel.selectedUserNames != [] {
                HStack{
                    Spacer()
                    VStack{
                        Spacer()
                        VStack(alignment: .trailing) {
                            ForEach(locationViewModel.selectedUserNames, id: \.self) { name in
                                Text(name) // Zeige jeden Namen an
                                    .font(.body)
                            }
                        }
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThickMaterial))
                        .cornerRadius(8)
                        .padding()
                    }
                }
            }

            
            



        }
    }
    private func addLocation() {
        let currentLocation = locationViewModel.mapLocation.center
        
        // Create a new CreatePosterPositionDTO object
        let newPosterPosition = CreatePosterPositionDTO(
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude,
            responsibleUsers: selectedUsers,
            expiresAt: expiresAt
        )
        locationViewModel.createPosterPosition(posterPosition: newPosterPosition, posterId: poster.id)
        // Add the new object to the list
        //createPosterPositions.append(newPosterPosition)
        
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            locationViewModel.fetchPosterPositions(poster: poster)
        }
    }
}

