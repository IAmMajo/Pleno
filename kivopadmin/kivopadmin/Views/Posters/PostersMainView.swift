import SwiftUI
import PosterServiceDTOs
import PhotosUI

struct PostersMainView: View {
    @StateObject private var locationViewModel = LocationsViewModel()
    @State private var isPostenSheetPresented = false // Zustand für das Sheet
    @State private var postersFiltered: [PosterResponseDTO] = []
    

    @StateObject private var posterManager = PosterManager() // MeetingManager als StateObject
    
    @State private var isLoading = false
    @State private var error: String?
    
    @State private var searchText = ""
    
    @State private var showDeleteConfirmation = false
    @State private var posterToDelete: UUID? // Die ID des Posters, das gelöscht werden soll
    @State private var isEditSheetPresented = false // Steuert das Sheet
    @State private var selectedPoster: PosterResponseDTO? // Das aktuell zu bearbeitende Poster
    

    
    var body: some View {
        NavigationStack {
            VStack {
                if posterManager.isLoading {
                    ProgressView("Lade Sammelposten...") // Ladeanzeige
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let errorMessage = posterManager.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else if posterManager.postersWithSummaries.isEmpty {
                    Text("Keine Sammelposten gefunden.")
                        .foregroundColor(.secondary)
                } else {
                    listView()
                }
            }
            
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Suchen")
            .navigationTitle("Plakate")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isPostenSheetPresented.toggle()
                    }) {
                        Text("Sammelposten erstellen") // Symbol für Übersetzung (Weltkugel)
                            .foregroundColor(.blue) // Blaue Farbe für das Symbol
                    }
                }
            }
        }
        .sheet(isPresented: $isPostenSheetPresented) {
            CreatePosterView(posterManager: posterManager)
        }
        .sheet(isPresented: $isEditSheetPresented) {
            if let selectedPoster = selectedPoster {
                EditPosterView(poster: selectedPoster)
            }
        }
        .onAppear(){
            posterManager.fetchPostersAndSummaries()
        }
        .alert("Sammelposten löschen", isPresented: $showDeleteConfirmation, actions: {
            Button("Löschen", role: .destructive) {
                if let posterId = posterToDelete {
                    // API-Aufruf mit der ID des Posters
                    posterManager.deletePoster(posterId: posterId, completion: { _ in
                        print("Gelöscht")
                    })
                    
                    // Lokale Liste nach kurzer Verzögerung aktualisieren
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        posterManager.fetchPoster()
                    }
                }
                posterToDelete = nil // Zurücksetzen
            }
            Button("Abbrechen", role: .cancel) {
                posterToDelete = nil // Zurücksetzen
            }
        })
        
    }
    
    
    private func deletePoster(poster: PosterResponseDTO) {
        // API-Aufruf mit der ID des Posters
        
        posterToDelete = poster.id
        showDeleteConfirmation = true
    }
    private func editPoster(poster: PosterResponseDTO) {
        selectedPoster = poster
        isEditSheetPresented = true
    }
    
    
}

extension PostersMainView {
    private func listView() -> some View {
        List {
            ForEach(posterManager.postersWithSummaries, id: \.poster.id) { posterWithSummary in
                PosterRowView(poster: posterWithSummary)
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            deletePoster(poster: posterWithSummary.poster)
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }
                    }
            }
        }
    }
    
}
struct PosterRowView: View {
    let poster: PosterWithSummary
    
    @StateObject private var locationViewModel = LocationsViewModel()
    
    var body: some View {
        NavigationLink(destination: LocationsView(poster: poster.poster).environmentObject(locationViewModel)) {
            VStack {
                HStack(spacing: 5) {
                    if let imageData = poster.image, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100) // Höhe einstellen
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                    VStack(){
                        Text(poster.poster.name)
                            .font(.title)
                        
                        HStack() {
                            if let summary = poster.summary {
                                CircularProgressView(poster: poster, status: .hangs).padding(.horizontal, 2)
                                CircularProgressView(poster: poster, status: .takenDown).padding(.horizontal, 2)
                                
                            }
                        }.padding(.horizontal, 6)
                            .padding(.top, 10)
                    }
                    Spacer()
                }
                Divider() // Dieser Divider nimmt die gesamte Breite der Zelle ein
                    .padding(.vertical, 5) // Optional: Abstand über und unter dem Divider
            }
        }
    }
}


