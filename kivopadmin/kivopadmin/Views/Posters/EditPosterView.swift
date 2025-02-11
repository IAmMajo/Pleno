import SwiftUI
import PhotosUI
import PosterServiceDTOs


struct EditPosterView: View {
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
                    // Bild anzeigen, wenn schon eins vorhanden ist
                    if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                        VStack {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                                .padding(.bottom, 10)
                            
                            // Bild entfernen
                            Button(action: {
                                // Bild entfernen
                                self.imageData = nil
                                self.selectedItem = nil
                            }) {
                                Text("Bild entfernen")
                                    .foregroundColor(.red)
                            }
                        }
                    // Bild auswählen, wenn noch keine Auswahl getroffen wurde
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
                // Button zum Speichern
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
            image: imageData ?? Data() // Falls kein neues Bild hochgeladen wurde, nutze das alte
        )
        
        // API-Aufruf zur Aktualisierung des Posters
        posterManager.patchPoster(poster: updatedPoster, posterId: poster.id)
    }
}
