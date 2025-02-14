// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



import SwiftUI
import PosterServiceDTOs
import PhotosUI

struct CreatePosterView: View {
    @Environment(\.dismiss) var dismiss
    
    // leere Variablen, um Sammelposten zu erstellen
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil // Optional Data für das Bild
    
    // ViewModel für Sammelposten
    @State var posterManager = PosterManager()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Allgemeine Informationen")) {
                    TextField("Titel", text: $title)
                    TextField("Beschreibung", text: $description)
                }
                
                Section(header: Text("Posterdesign")) {
                    // Bild für den Sammelposten
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
        
        posterManager.createPoster(poster: newPoster)
        
        // Eine Sekunde warten, damit das Backend die Anfrage verarbeiten kann und der neue Sammelposten berücksichtigt werden kann.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            posterManager.fetchPoster()
        }
        
        dismiss()
    }
}
