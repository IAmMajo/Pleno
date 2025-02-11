import SwiftUI
import PosterServiceDTOs
import PhotosUI

struct CreatePosterView: View {
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
