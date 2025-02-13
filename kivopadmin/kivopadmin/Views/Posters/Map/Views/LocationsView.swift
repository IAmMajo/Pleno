// This file is licensed under the MIT-0 License.

import SwiftUI
import PosterServiceDTOs
import MapKit

// MainView für deinen Sammelposten (Karte)
struct LocationsView: View {
    // locationViewModel als EnvironmentObject
    @EnvironmentObject private var locationViewModel: LocationsViewModel
    
    // Startwert für die Karte -> Hier: Datteln
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.6542, longitude: 7.3556),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // Bool Variable: Ist die Suche aktiviert?
    @State private var isSearchActive = false
    
    // Suchtext
    @State private var searchText = ""
    
    // Bool Variable, ob das Filter Menu gezeigt werden soll
    @State private var showMenu = false
    
    // Verfallsdatum
    @State private var expiresAt: Date = Date()
    
    // Verantwortliche User. Ist zunächst leer
    @State private var selectedUsers: [UUID] = []
    
    // Bool Variable für das User Selection Sheet
    @State private var showUserSelectionSheet = false
    
    // Variable für den aktuellen Standort
    @State private var currentLocation: CLLocationCoordinate2D?

    // Optionen für den Filter, um nach Plakatpositionen zu suchen
    private var filterOptions: [PosterPositionStatus] = [.toHang, .hangs, .damaged, .overdue, .takenDown]
    
    // ViewModel für die Nutzerverwaltung
    @ObservedObject var userManager = UserManager()
    
    // Sammelposten
    var poster: PosterResponseDTO
    
    // Maximale Breite der Liste (oben) und der PlakatPosition (unten)
    let maxWidth: CGFloat = 700
    
    init(poster: PosterResponseDTO) {
        self.poster = poster
    }
    
    var body: some View {
        ZStack {
            // Karte
            mapLayer
            
            // Wenn der Benutzer Plakatpositionen hinzufügen will, wird editingView gezeigt
            if locationViewModel.isEditing{
                editingView
            }
            VStack {
                HStack(alignment: .top){
                    VStack{
                        // Filter, um bestimmte Plakatpositionen zu zeigen
                        filterButton
                        if showMenu{
                            filterMenu
                        }
                    }
                    Spacer()
                    // Zeige die Adresse oder lade sie asynchron
                    VStack{
                        // Wenn die Suche aktiv ist, zeigt das Textfeld an
                        if isSearchActive {
                            // Searchbar, um Karte zu einer Adresse zu bewegen
                            searchBarSection
                        } else {
                            // Dropdown Liste mit Plakatpositionen
                            dropdownSection
                        }
                    }
                    Spacer()
                    VStack{
                        // Button, der die Suchfunktion auslöst
                        searchButton
                        
                        // Button, ob isEditing zu togglen
                        editButton
                        
                        // Button, um zwischen Satellitenansicht und normaler Ansicht zu wechseln
                        mapStyleButton
                    }
                }
                Spacer()
                
                // Untere Ansicht in der Karte (View: LocationPreviewView)
                // nur sichtbar, wenn ein Marker angeklickt wird oder in der Dropdown Liste eine Auswahl getroffen wird
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
            locationViewModel.fetchPosterSummary(poster: poster)
            userManager.fetchUsers()
        }
    }
    
    
    private var mapLayer: some View {
        Map(position: $locationViewModel.mapCameraPosition) {
            // Annotationen für Standorte hinzufügen
            ForEach(locationViewModel.filteredPositions) { position in
                // Marker in der Karte
                Annotation(position.address, coordinate: CLLocationCoordinate2D(latitude: position.position.latitude, longitude: position.position.longitude)) {
                    // Ansicht der Marker
                    LocationMapAnnotationView(position: position)
                        .scaleEffect(locationViewModel.selectedPosterPosition == position ? 1 : 0.6)
                        .shadow(radius: 10)
                        // Aktionen, wenn auf einen Marker geklickt wird
                        .onTapGesture {
                            withAnimation {
                                locationViewModel.isEditing = false
                            }
                            locationViewModel.showNextLocation(location: position)
                        }
                }
            }
        }
        // Satelliten- oder normale Ansicht
        .mapStyle(locationViewModel.satelliteView ? .imagery : .standard)
        // Standort aktualisieren wenn der Nutzer die Karte bewergt
        // Wird für addLocation() benötigt, wo der aktuelle Standort ausgelesen wird
        .onMapCameraChange { mapCameraUpdateContext in
            currentLocation = mapCameraUpdateContext.camera.centerCoordinate
        }
    }

    
    // Suchleiste
    private var searchBarSection: some View {
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
    }
    
    // Dropdown Liste
    private var dropdownSection: some View {
        VStack{
            Button(action: {
                locationViewModel.toggleLocationsList()
                withAnimation {
                    // Wenn die Liste ausgeklappt wird, wird der Bearbeitungsmodus deaktiviert
                    locationViewModel.isEditing = false
                }
            }){
                // Ansicht der "Überschrift" der Liste
                Text(locationViewModel.selectedPosterPosition?.address ?? "Wählen Sie eine Position aus").foregroundColor(.primary).frame(height: 55).frame(maxWidth: .infinity)
                    .overlay(alignment: .leading){
                        Image(systemName: "arrow.down").font(.headline).foregroundColor(.primary).padding().rotationEffect(Angle(degrees: locationViewModel.showLocationsList ? 180 : 0))
                    }
            }
            // Liste wird angezeigt, wenn showLocationsList true ist
            if locationViewModel.showLocationsList{
                LocationsListView()
            }
            
            
        }.background(.thickMaterial).cornerRadius(10).shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 15)
            .padding()
            .frame(maxWidth: maxWidth)
    }
    
    // Button, um die Suche nach einem Ort zu starten
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
    
    // Button, der das Filter Menu einblendet
    private var filterButton: some View {
        Button {
            withAnimation {
                showMenu.toggle()  // Sichtbarkeit des Menüs umschalten
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle").font(.headline).padding(16).foregroundColor(.primary).background(.thickMaterial).cornerRadius(10).shadow(radius: 4).padding()
        }
    }
    
    // FilterMenu, um nach einem bestimmten Status in der Karte zu filtern
    private var filterMenu: some View {
        VStack(spacing: 20) {
            // Für jede FilterOption wird ein Icon angezeigt
            ForEach(filterOptions, id: \.self) { option in
                HStack{
                    ZStack{
                        // ausgewählter Filter wird hervorgehoben
                        if option == locationViewModel.selectedFilter{
                            RoundedRectangle(cornerRadius: 8) // Abgerundete Ecken
                                .fill(Color.gray.opacity(0.2)) // Farbe und Transparenz
                                .frame(width: 60, height: 30)
                        }
                        // Button, um Filter auszuwählen
                        Button(action: {
                            withAnimation {
                                if option == locationViewModel.selectedFilter{
                                    locationViewModel.selectedFilter = nil
                                } else {
                                    locationViewModel.selectedFilter = option
                                }
                            }
                        }) {
                            let icon = PosterHelper.getFilterIcon(for: option)
                            Image(systemName: icon.symbol)
                                .foregroundColor(icon.color)
                            Text(getSummaryCount(for: option))
                        }
                        .buttonStyle(.plain)
                        
                        
                    }
                }
                
            }
        }
        .padding(8)
        .padding(.vertical, 4)
        .background(.thickMaterial)
        .cornerRadius(10)
        .shadow(radius: 4)
        
    }
    // Button, um den Bearbeitungsmodus zu aktivieren
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
    
    // Button, um den Stil der Karte anzupassen
    private var mapStyleButton: some View {
        Button {
            locationViewModel.satelliteView.toggle()  // Umschalten der Kartenansicht
        } label: {
            Image(systemName: locationViewModel.satelliteView ? "map" : "globe.americas")
                .font(.headline)
                .padding(16)
                .foregroundColor(.primary)
                .background(.thickMaterial)
                .cornerRadius(10)
                .shadow(radius: 4)
                .padding()
        }
    }
    
    // liefert die Anzahl der PlakatPositionen nach Status
    func getSummaryCount(for status: PosterPositionStatus) -> String {
        switch status {
        case .toHang:
            return "\(locationViewModel.summary?.toHang ?? 0)" // Defaultwert 0, wenn nil
        case .hangs:
            return "\(locationViewModel.summary?.hangs ?? 0)" // Defaultwert 0, wenn nil
        case .overdue:
            return "\(locationViewModel.summary?.overdue ?? 0)" // Defaultwert 0, wenn nil
        case .takenDown:
            return "\(locationViewModel.summary?.takenDown ?? 0)" // Defaultwert 0, wenn nil
        case .damaged:
            return "\(locationViewModel.summary?.damaged ?? 0)"
        default:
            return "?"
        }
    }
    
    // Suche nach einem Ort/Adresse
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
                
                // der user wird zu dem Ort geführt
                locationViewModel.mapCameraPosition = .region(
                    MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
                    )
                )
            }
        }
    }
    
    // Ansicht des Bearbeitungsmodus
    private var editingView: some View {
        ZStack{
            VStack {
                Spacer()
                // Fadenkreuz, genau auf der Mitte des Bildschirms
                fadenkreuz
                Spacer()
            }
            VStack{
                Spacer()
                HStack(alignment: .bottom){
                    VStack(alignment: .leading, spacing: 8) {
                        // Auswahlmöglichkeit für das Ablaufdatum
                        ablaufDatum
                        
                        // Verantwortliche Personen anzeigen
                        selectResponsibleUsers
                        
                        // Plakatposition hinzufügen
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
            
            // Wenn Benutzer als Verantwortliche Personen ausgewählt wurden, erscheinen sie im unteren, rechten Bildschirmrand
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
    private var fadenkreuz: some View {
        ZStack {
            Rectangle()
                .frame(width: 1, height: 30)
                .foregroundColor(.blue)
            Rectangle()
                .frame(width: 30, height: 1)
                .foregroundColor(.blue)
        }
    }
    
    private var ablaufDatum: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Ablaufdatum")
                .font(.caption)
                .foregroundColor(.primary)
            DatePicker("Datum", selection: $expiresAt, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .cornerRadius(10)
        }
    }
    
    private var selectResponsibleUsers: some View {
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
    }
    
    // Plakatposition hinzufügen
    private func addLocation() {
        
        // CreatePosterPositionDTO befüllen
        if let currentLocation = currentLocation {
            let newPosterPosition = CreatePosterPositionDTO(
                latitude: currentLocation.latitude,
                longitude: currentLocation.longitude,
                responsibleUsers: selectedUsers,
                expiresAt: expiresAt
            )
            
            // Positition an den Server schicken
            locationViewModel.createPosterPosition(posterPosition: newPosterPosition, posterId: poster.id)
                    
            // Eine Sekunde warten, damit der Server die neuen Daten verarbeiten kann
            // Dann kann erneut ein GET durchgeführt werden und die neusten Daten sind vorhanden
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                locationViewModel.fetchPosterPositions(poster: poster)
            }
        }
        

    }
}

