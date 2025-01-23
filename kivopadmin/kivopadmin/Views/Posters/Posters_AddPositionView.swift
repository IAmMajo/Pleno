import Foundation
import SwiftUI
import MapKit
import PosterServiceDTOs
import AuthServiceDTOs

struct User: Identifiable {
    let id = UUID()
    let name: String
}



struct CustomMapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var createPosterPositions: [CreatePosterPositionDTO]
    var onRegionChange: (MKCoordinateRegion) -> Void
    var posterPositions: [PosterPositionResponseDTO]
    var poster: PosterResponseDTO
    var onMarkerSelected: (PosterPositionResponseDTO) -> Void  // Closure, das den ausgewählten Marker verarbeitet

    
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView

        init(parent: CustomMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            parent.onRegionChange(mapView.region)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "CustomAnnotation"

            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }

            if let position = parent.posterPositions.first(where: { $0.latitude == annotation.coordinate.latitude && $0.longitude == annotation.coordinate.longitude }) {
                var color: UIColor = .gray
                switch position.status {
                case "toHang":
                    color = .blue
                case "overdue":
                    color = .green
                case "hangs":
                    color = .red
                case "takenDown":
                    color = .yellow
                default:
                    color = .gray
                }
            }

            return annotationView
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation else { return }
            // Hier rufen wir den Closure auf, um das Sheet zu öffnen
            print("Marker angeklickt")
            
            if let selectedPosition = parent.posterPositions.first(where: { $0.latitude == annotation.coordinate.latitude && $0.longitude == annotation.coordinate.longitude }) {
                parent.onMarkerSelected(selectedPosition)
                print("Marker angeklickt")
            }
        }
        
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.mapType = .standard
        mapView.showsUserLocation = false
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        let poiFilter = MKPointOfInterestFilter(including: [])
        mapView.pointOfInterestFilter = poiFilter
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)
        uiView.removeAnnotations(uiView.annotations)
        
        

        for position in createPosterPositions {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
            uiView.addAnnotation(annotation)
            
        }
        for position in posterPositions {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
            uiView.addAnnotation(annotation)

        }
    }
}



struct Posters_AddPositionView: View {
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
    @State private var selectedPosterPosition: PosterPositionResponseDTO? = nil // State für das ausgewählte Poster
    
    @State var isEditing: Bool = false
    
    @State private var positionColor: Color = .blue

    var poster: PosterResponseDTO
    
    // Array to hold CreatePosterPositionDTO objects
    @State private var createPosterPositions: [CreatePosterPositionDTO] = []

    var body: some View {
        HStack {
            VStack{
                
                if posterManager.isLoading {
                    ProgressView("Loading...")
                } else if let errorMessage = posterManager.errorMessage {
                    Text("Error: \(errorMessage)").foregroundColor(.red)
                } else {
                    // Zeige die Liste der Positionen
                    List(posterManager.posterPositions, id: \.id) { posterLocation in
                        Button(action: {
                            zoomToLocation(latitude: posterLocation.latitude, longitude: posterLocation.longitude)
                        }) {
                            VStack(alignment: .leading) {
                                Text("Lat: \(posterLocation.latitude), Lon: \(posterLocation.longitude)")
                                    .font(.body)
                                Text("Läuft ab: \(DateTimeFormatter.formatDate(posterLocation.expiresAt))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .navigationTitle("Plakatpositionen")
                }
            }.frame(width: 300)

            VStack {

                
                ZStack {
                    Map(
//                        region: $mapRegion,
//                        createPosterPositions: createPosterPositions,
//                        onRegionChange: { newRegion in mapRegion = newRegion },
//                        posterPositions: posterManager.posterPositions,
//                        poster: poster,
//                        onMarkerSelected: { selectedPosition in
//                            selectedPosterPosition = selectedPosition // Update den Wert beim Marker-Klick
//                        }
                    ){
                        ForEach(posterManager.posterPositions, id: \.id) { position in
                            let positionColor: Color = {
                                switch position.status {
                                case "toHang": return .orange
                                case "overdue": return .red
                                case "hangs": return .green
                                case "takenDown": return .gray
                                default: return .blue
                                }
                            }()

                            Marker("", systemImage: "car", coordinate: CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude))
                                .tint(positionColor)
                        }
                        
                    }
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
                            Button(action: {
                                isEditing.toggle()  // Hier wird der Zustand von `isEditing` umgeschaltet
                            }) {
                                HStack {
                                    Image(systemName: "pencil")  // Das Symbol für den Button
                                    Text("Bearbeiten")  // Der Text des Buttons
                                        .font(.headline)  // Optional: Du kannst die Schriftart anpassen
                                }
                                .padding()  // Padding für den Button
                                .background(Color.blue)  // Hintergrundfarbe des Buttons
                                .foregroundColor(.white)  // Textfarbe des Buttons
                                .cornerRadius(10)  // Abgerundete Ecken
                                .shadow(radius: 5)  // Optional: Ein Schatten für den Button
                            }

                            .padding()
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
                    if isEditing{
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
                    }


                    VStack {
                        Spacer()
                        HStack {

                            if isEditing{
                                VStack(alignment: .leading, spacing: 8) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Ablaufdatum")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                        DatePicker("Datum", selection: $expiresAt, displayedComponents: .date)
                                            .datePickerStyle(.compact)
                                            .labelsHidden()
                                            .background(Color.white)
                                            .cornerRadius(8)
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Benutzer auswählen")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                        Button(action: {
                                            showUserSelectionSheet.toggle()
                                        }) {
                                            Text("Benutzer auswählen")
                                                .padding()
                                                .background(Color.white)
                                                .cornerRadius(8)
                                        }
                                    }
                                    Button(action: addLocation) {
                                        Text("Standort hinzufügen")
                                            .padding()
                                            .background(Color.blue)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                }
                                .padding(8)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(8)
                            }

                            Spacer()
                            VStack {
                                Button(action: zoomIn) {
                                    Image(systemName: "plus.magnifyingglass")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.blue)
                                        .padding()
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 10)
                                }
                                
                                Button(action: zoomOut) {
                                    Image(systemName: "minus.magnifyingglass")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.blue)
                                        .padding()
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 10)
                                }
                            }
                            .padding()
                        }
                        .padding()
                    }
                }
            }
        }
        .sheet(item: $selectedPosterPosition) { position in
            PosterDetailsView(position: position) // Deine View für Details
        }
        .sheet(isPresented: $showUserSelectionSheet) {
            UserSelectionSheet(users: userManager.users, selectedUsers: $selectedUsers)
        }
        .onAppear {
            // Benutzer laden, wenn die View erscheint
            userManager.fetchUsers()
            posterManager.fetchPosterPositions(poster: poster)
        }
    }

    private func addLocation() {
        let currentLocation = mapRegion.center
        
        // Create a new CreatePosterPositionDTO object
        let newPosterPosition = CreatePosterPositionDTO(
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude,
            responsibleUsers: selectedUsers,
            expiresAt: expiresAt
        )
        posterManager.createPosterPosition(posterPosition: newPosterPosition, posterId: poster.id)
        // Add the new object to the list
        //createPosterPositions.append(newPosterPosition)
        
        posterManager.fetchPosterPositions(poster: poster)
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

    private func zoomIn() {
        let newSpan = MKCoordinateSpan(
            latitudeDelta: mapRegion.span.latitudeDelta * 0.8,
            longitudeDelta: mapRegion.span.longitudeDelta * 0.8
        )
        mapRegion.span = newSpan
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
    
    private func zoomOut() {
        let newSpan = MKCoordinateSpan(
            latitudeDelta: mapRegion.span.latitudeDelta * 1.2,
            longitudeDelta: mapRegion.span.longitudeDelta * 1.2
        )
        mapRegion.span = newSpan
    }
}

//struct PosterRowMiniView: View {
//
//    var body: some View {
//        Text("Hallo")
//    }
//
//}
//
//

struct PosterDetailsView: View {
    var position: PosterPositionResponseDTO

    var body: some View {
        VStack {
            Text("Details für den Marker")
                .font(.headline)
            Text("Latitude: \(position.latitude), Longitude: \(position.longitude)")
            Text("Status: \(position.status)")
            // Weitere Detailinformationen anzeigen
        }
        .padding()
    }
}

struct UserSelectionSheet: View {
    var users: [UserProfileDTO]
    @Binding var selectedUsers: [UUID]
    @State private var searchText: String = ""
    
    @ObservedObject var userManager = UserManager()

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredUsers, id: \.email) { user in
                    HStack {
                        Text(user.name ?? "Unbekannter Name") // Fallback, falls name nil ist
                        Spacer()
                        if let uid = user.uid, selectedUsers.contains(uid) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        toggleSelection(for: user)
                    }
                }
            }
            .navigationTitle("Benutzer auswählen")
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        print(userManager.users)
                        dismiss()
                    }
                }
            }
        }
        .onAppear(){
            userManager.fetchUsers()
        }
    }

    private var filteredUsers: [UserProfileDTO] {
        if searchText.isEmpty {
            return userManager.users
        } else {
            return userManager.users.filter { user in
                if let name = user.name {
                    return name.localizedCaseInsensitiveContains(searchText)
                }
                return false
            }
        }
    }

    private func toggleSelection(for user: UserProfileDTO) {
        if let uid = user.uid {
            if let index = selectedUsers.firstIndex(of: uid) {
                selectedUsers.remove(at: index)
            } else {
                selectedUsers.append(uid)
            }
        }
    }

    private func dismiss() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.dismiss(animated: true, completion: nil)
        }
    }
}

//
//#Preview {
//    Posters_AddPositionView()
//}

extension PosterPositionResponseDTO: Identifiable {}
