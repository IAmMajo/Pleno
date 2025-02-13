// This file is licensed under the MIT-0 License.

import SwiftUI
import PhotosUI
import PosterServiceDTOs


struct EditPosterView: View {
    @Environment(\.dismiss) var dismiss

    // Sammelposten wird beim Aufruf übergeben
    var poster: PosterResponseDTO
    
    // Aktuelles Bild wird beim Aufruf übergeben
    var image: Data
    
    // Variablen für hochgeladenes Bild
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil // Optional Data für das Bild
    @State private var title: String // Titel des Posters
    @State private var description: String // Beschreibung des Posters
    
    // ViewModel als EnvironmentObject
    @EnvironmentObject private var posterManager: PosterManager
    
    // Initialisierer, um beim Aufruf die Werte zuzuweisen
    init(poster: PosterResponseDTO, image: Data) {
        self.poster = poster
        self.image = image
        _title = State(initialValue: poster.name)
        _description = State(initialValue: poster.description ?? "")
        _imageData = State(initialValue: image) // Richtig: State korrekt initialisieren
    }

    
    var body: some View {
        NavigationView {
            Form {
                // Hier können Name und Beschreibung angepasst werden
                titleDescription
                
                // Hier wird das Foto angepasst
                Section(header: Text("Posterdesign")) {
                    
                    // Bild anzeigen, wenn schon eins vorhanden ist
                    if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                        existingImage(uiImage: uiImage)
                        
                    // Bild auswählen, wenn noch keine Auswahl getroffen wurde
                    } else {
                        newImage
                    }
                }
                // Button zum Speichern
                saveButton
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
        
        // DTO befüllen
        let updatedPoster = CreatePosterDTO(
            name: title,
            description: description,
            image: imageData ?? Data() // Falls kein neues Bild hochgeladen wurde, nutze das alte
        )
        
        // API-Aufruf zur Aktualisierung des Posters
        posterManager.patchPoster(poster: updatedPoster, posterId: poster.id)
        
        // kurz warten, um die Sammelposten erneut zu laden
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            posterManager.fetchPostersAndSummaries()
        }
        dismiss()
    }
}

extension EditPosterView {
    private var titleDescription: some View {
        Section(header: Text("Allgemeine Informationen")) {
            TextField("Titel", text: $title)
            TextField("Beschreibung", text: $description)
        }
    }
    
    // Bild anzeigen
    private func existingImage(uiImage: UIImage) -> some View {
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
    }
    
    // neues Bild hochladen
    private var newImage: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            Text("Bild hochladen")
                .foregroundColor(.blue)
        }
        .onChange(of: selectedItem) {
            Task {
                if let selectedItem, let data = try? await selectedItem.loadTransferable(type: Data.self) {
                    imageData = data
                }
            }
        }
    }
    
    // Button zum speichern
    private var saveButton: some View {
        Button(action: saveSammelposten) {
            Text("Sammelposten speichern")
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .foregroundColor(.white)
        .padding()
        .background(Color.blue)
        .cornerRadius(10)
    }
}
