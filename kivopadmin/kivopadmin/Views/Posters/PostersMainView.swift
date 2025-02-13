// This file is licensed under the MIT-0 License.

import SwiftUI
import PosterServiceDTOs
import PhotosUI

struct PostersMainView: View {
    // locationViewModel wird hier initialisiert und an alle "Unter-Views" weitergegeben
    @StateObject private var locationViewModel = LocationsViewModel()
    
    // Bool für Sheet
    @State private var isPostenSheetPresented = false
    
    // ViewModel für Sammelposten
    @StateObject private var posterManager = PosterManager()

    // Suchtext
    @State private var searchText = ""
    
    // Bool für Delete Confirmation
    @State private var showDeleteConfirmation = false
    
    @State private var posterToDelete: UUID? // Die ID des Posters, das gelöscht werden soll
    @State private var isEditSheetPresented = false // Steuert das Sheet
    @State private var selectedPoster: PosterResponseDTO? // Das aktuell zu bearbeitende Poster
    

    var filteredPosters: [PosterWithSummary] {
        if searchText.isEmpty {
            return posterManager.postersWithSummaries
        } else {
            return posterManager.postersWithSummaries.filter {
                $0.poster.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
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
                    // Wenn die Sammelposten geladen wurden, wird die Liste angezeigt
                    //listView()
                    forEachPoster
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
        // Sheet um Sammelposten zu erstellen
        .sheet(isPresented: $isPostenSheetPresented) {
            CreatePosterView(posterManager: posterManager)
        }
        
        // Sheet um Sammelposten zu bearbeiten
        .sheet(isPresented: $isEditSheetPresented) {
            if let selectedPoster = selectedPoster {
                EditPosterView(poster: selectedPoster)
            }
        }
        .onAppear(){
            posterManager.fetchPostersAndSummaries()
        }
        // Confirmation Alert -> der Nutzer soll das Löschen bestätigen
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
    private var forEachPoster: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())] // Zwei Spalten
        
        return
        ScrollView{
            LazyVGrid(columns: columns, spacing: 16) {
                
                ForEach(filteredPosters, id: \.poster.id) { posterWithSummary in
                    NavigationLink(destination: LocationsView(poster: posterWithSummary.poster).environmentObject(locationViewModel)) {
                        posterListElement(poster: posterWithSummary)// Deine Poster-View hier einfügen
                            .frame(maxWidth: .infinity)
                            .padding(4)
                            .contextMenu { // Kontextmenü für langes Drücken
                                Button(role: .destructive) {
                                    deletePoster(poster: posterWithSummary.poster)
                                } label: {
                                    Label("Löschen", systemImage: "trash")
                                }
                            }
                    }
                }
            }.padding(.horizontal)
        }
    }
    
    private func posterListElement(poster: PosterWithSummary) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThickMaterial)
            
            HStack(spacing: 5) {
                if let imageData = poster.image, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 140) // Höhe einstellen
                        .cornerRadius(10)
                        .padding(.leading)
                }
                Spacer()
                VStack(alignment: .trailing){
                    Text(poster.poster.name)
                        .font(.title2)
                    Spacer()
                    VStack(alignment: .trailing) {
                        if let summary = poster.summary {
                            CircularProgressView(poster: poster, status: .hangs).padding(.horizontal, 2)
                            CircularProgressView(poster: poster, status: .takenDown).padding(.horizontal, 2)
                            
                        }
                    }.padding(.horizontal, 6)
                }.padding(.trailing)

            }.padding(.vertical)
        }
    }
    
}
