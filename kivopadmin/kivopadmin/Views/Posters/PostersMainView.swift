import SwiftUI
import PosterServiceDTOs
import PhotosUI

struct PostersMainView: View {
    @StateObject private var locationViewModel = LocationsViewModel()
   @State private var isPostenSheetPresented = false // Zustand für das Sheet
    @State private var postersFiltered: [PosterResponseDTO] = []
   
   @StateObject private var postersViewModel = PostersViewModel()
    @StateObject private var posterManager = PosterManager() // MeetingManager als StateObject
   
   @State private var isLoading = false
   @State private var error: String?
   
   @State private var searchText = ""
    
    @State private var showDeleteConfirmation = false
    @State private var posterToDelete: UUID? // Die ID des Posters, das gelöscht werden soll
    @State private var isEditSheetPresented = false // Steuert das Sheet
    @State private var selectedPoster: PosterResponseDTO? // Das aktuell zu bearbeitende Poster
   
   let numberOfPostersToHang = [1, 0, 4]
    
   
//   Calendar.current.isDateInTomorrow(yourDate)
   
   func getDateColor(status: Status) -> Color {
      switch status {
      case .hung:
         return Color(UIColor.darkText)
      case .takenDown:
         return Color(UIColor.darkText)
      case .notDisplayed:
         return Color(UIColor.darkText)
      case .expiresInOneDay:
         return .orange
      case .expired:
         return .red
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
            SammelpostenErstellenView(posterManager: posterManager)
        }
        .sheet(isPresented: $isEditSheetPresented) {
            if let selectedPoster = selectedPoster {
                SammelpostenBearbeitenView(poster: selectedPoster)
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
                    if let uiImage = UIImage(data: poster.poster.image) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100) // Höhe einstellen
                            .cornerRadius(10)
                    }
                    Spacer()
                    VStack(alignment: .leading){
                        Text(poster.poster.name)
                            .font(.title)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        if let summary = poster.summary {
                            Text("Hängt noch nicht: \(summary.toHang)")
                            Text("Hängt: \(summary.hangs)")
                            Text("Beschädigt: \(summary.damaged)")
                            Text("Überfällig: \(summary.overdue)")
                            Text("Abgehangen: \(summary.takenDown)")
//                            Spacer()
//                            HStack(alignment: .bottom, spacing: 12){
//                                
//                                summaryItem(title: "Hängt noch nicht", value: summary.toHang)
//                                summaryItem(title: "Hängt", value: summary.hangs)
//                                summaryItem(title: "Beschädigt", value: summary.damaged)
//                                summaryItem(title: "Überfällig", value: summary.overdue)
//                                summaryItem(title: "Abgehangen", value: summary.takenDown)
//                                
//                            }

                        }
                    }.padding(.horizontal, 6)
                }
                Divider() // Dieser Divider nimmt die gesamte Breite der Zelle ein
                    .padding(.vertical, 5) // Optional: Abstand über und unter dem Divider
            }
        }
    }
    
    private func summaryItem(title: String, value: Int) -> some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(2) // Verhindert Zeilenumbrüche
                //.fixedSize(horizontal: false, vertical: true) // Erzwingt einzeilige Darstellung

            
            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
                .padding()
                .frame(width: 60, height: 50)
                .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThickMaterial))
        }
    }
}



struct SammelpostenErstellenView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil // Optional Data für das Bild
    @State var posterManager = PosterManager()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Allgemeine Informationen")) {
                    TextField("Titel", text: $title)
                    TextField("Beschreibung", text: $description)
                }

                Section(header: Text("Posterdesign")) {
                    if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                        VStack {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                                .padding(.bottom, 10)

                            Button(action: {
                                // Bild entfernen
                                self.imageData = nil
                                self.selectedItem = nil
                            }) {
                                Text("Bild entfernen")
                                    .foregroundColor(.red)
                            }
                        }
                    } else {
                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Text("Bild hochladen")
                                .foregroundColor(.blue)
                        }
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    self.imageData = data
                                }
                            }
                        }
                    }
                }

                Button(action: saveSammelposten) {
                    Text("Sammelposten erstellen")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
            .navigationTitle("Sammelposten erstellen")
        }
    }

    // Funktion zum Speichern des Sammelpostens
    private func saveSammelposten() {
        guard !title.isEmpty, let imageData = imageData else {
            print("Titel oder Bild fehlt!")
            return
        }
            
        let newPoster = CreatePosterDTO(
            name: title,
            description: description,
            image: imageData
        )
        
        //posterManager.createPoster(poster: newPoster)
        posterManager.createPoster(poster: newPoster)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            posterManager.fetchPoster()
        }
        
        dismiss()
    }
}

struct SammelpostenBearbeitenView: View {
    @Environment(\.dismiss) var dismiss
    var poster: PosterResponseDTO // Übergabe des Posters zur Bearbeitung
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil // Optional Data für das Bild
    @State private var title: String // Titel des Posters
    @State private var description: String // Beschreibung des Posters
    @State private var posterManager = PosterManager()

    init(poster: PosterResponseDTO) {
        self.poster = poster
        _title = State(initialValue: poster.name) // Initialisiere den Titel
        _description = State(initialValue: poster.description ?? "") // Initialisiere die Beschreibung
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Allgemeine Informationen")) {
                    TextField("Titel", text: $title)
                    TextField("Beschreibung", text: $description)
                }

                Section(header: Text("Posterdesign")) {
                    if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                        VStack {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                                .padding(.bottom, 10)

                            Button(action: {
                                // Bild entfernen
                                self.imageData = nil
                                self.selectedItem = nil
                            }) {
                                Text("Bild entfernen")
                                    .foregroundColor(.red)
                            }
                        }
                    } else {
                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Text("Bild hochladen")
                                .foregroundColor(.blue)
                        }
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    self.imageData = data
                                }
                            }
                        }
                    }
                }

                Button(action: saveSammelposten) {
                    Text("Sammelposten speichern")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
            .navigationTitle("Sammelposten bearbeiten")
        }
    }

    // Funktion zum Speichern des Sammelpostens
    private func saveSammelposten() {
        guard !title.isEmpty else {
            print("Titel fehlt!")
            return
        }
        
        let updatedPoster = CreatePosterDTO(
            name: title,
            description: description,
            image: imageData ?? poster.image // Falls kein neues Bild hochgeladen wurde, nutze das alte
        )
        
        // API-Aufruf zur Aktualisierung des Posters
        posterManager.patchPoster(poster: updatedPoster, posterId: poster.id)
    }
}
