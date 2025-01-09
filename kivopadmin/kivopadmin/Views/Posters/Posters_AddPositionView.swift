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
    var posterPositions: [CreatePosterPositionDTO]
    var onRegionChange: (MKCoordinateRegion) -> Void

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView

        init(parent: CustomMapView) {
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

        // Debugging output
        print("Updating map with \(posterPositions.count) positions")
        
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
    
    @State private var expiresAt: Date = Date()
    @State private var showUserSelectionSheet = false
    @State private var selectedUsers: [UUID] = []

    
    // Array to hold CreatePosterPositionDTO objects
    @State private var posterPositions: [CreatePosterPositionDTO] = []

    var body: some View {
        HStack {
            // List of Poster Positions
            List(posterPositions, id: \.posterId) { posterLocation in
                Button(action: {
                    zoomToLocation(latitude: posterLocation.latitude, longitude: posterLocation.longitude)
                }) {
                    Text("Lat: \(posterLocation.latitude), Lon: \(posterLocation.longitude)")
                        .font(.body)
                }
            }
            .frame(width: 300)
            .background(Color.gray.opacity(0.1))
            
//            if posterManager.isLoading {
//                ProgressView("Loading...")
//            } else if let errorMessage = posterManager.errorMessage {
//                Text("Error: \(errorMessage)").foregroundColor(.red)
//            } else {
//                // Zeige die Liste der Positionen
//                List(posterManager.positions, id: \.posterId) { posterLocation in
//                    Button(action: {
//                        zoomToLocation(latitude: posterLocation.latitude, longitude: posterLocation.longitude)
//                    }) {
//                        Text("Lat: \(posterLocation.latitude), Lon: \(posterLocation.longitude)")
//                            .font(.body)
//                    }
//                }
//                .frame(width: 300)
//                .background(Color.gray.opacity(0.1))
//            }

            VStack {
                ZStack {
                    CustomMapView(region: $mapRegion, posterPositions: posterPositions, onRegionChange: { newRegion in
                        mapRegion = newRegion
                    })
                    .ignoresSafeArea()
                        .frame(maxHeight: .infinity)

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
                            }
                            .padding(8)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(8)
                            Spacer()
                            Button(action: addLocation) {
                                Text("Standort hinzufügen")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
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
        .sheet(isPresented: $showUserSelectionSheet) {
            UserSelectionSheet(users: userManager.users, selectedUsers: $selectedUsers)
        }
        .onAppear {
            // Benutzer laden, wenn die View erscheint
            userManager.fetchUsers()
            posterManager.fetchPosterPositions()
        }
    }

    private func addLocation() {
        let currentLocation = mapRegion.center
        
        // Create a new CreatePosterPositionDTO object
        let newPosterPosition = CreatePosterPositionDTO(
            posterId: UUID(),
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude,
            responsibleUsers: selectedUsers,
            expiresAt: expiresAt
        )
        
        // Add the new object to the list
        posterPositions.append(newPosterPosition)
        
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

    private func zoomOut() {
        let newSpan = MKCoordinateSpan(
            latitudeDelta: mapRegion.span.latitudeDelta * 1.2,
            longitudeDelta: mapRegion.span.longitudeDelta * 1.2
        )
        mapRegion.span = newSpan
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


#Preview {
    Posters_AddPositionView()
}
