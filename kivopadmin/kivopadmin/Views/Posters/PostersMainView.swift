import SwiftUI
import PosterServiceDTOs
import PhotosUI

struct PostersMainView: View {
   @State private var isPostenSheetPresented = false // Zustand für das Sheet
    @State private var postersFiltered: [PosterResponseDTO] = []
   
   @StateObject private var postersViewModel = PostersViewModel()
    @StateObject private var posterManager = PosterManager() // MeetingManager als StateObject
   
   @State private var isLoading = false
   @State private var error: String?
   
   @State private var searchText = ""
   
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
                    ProgressView("Loading meetings...") // Ladeanzeige
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let errorMessage = posterManager.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else if posterManager.posters.isEmpty {
                    Text("No posters available.")
                        .foregroundColor(.secondary)
                } else {
                    
                    // Liste der Meetings
                    List {
                        ForEach(posterManager.posters, id: \.id) { poster in
                            PosterRowView(poster: poster) // Unterview
                        }
                    }
                }
            }

            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Suchen")
            .onChange(of: searchText) { newValue in
                Task {
                    if newValue.isEmpty {
                        postersFiltered = posterManager.posters
                    } else {
                        postersFiltered = posterManager.posters.filter { poster in
                            poster.name.localizedCaseInsensitiveContains(newValue)
                        }
                    }
                }
            }
            .navigationTitle("Plakate")
        }
        .sheet(isPresented: $isPostenSheetPresented) {
            SammelpostenErstellenView()
        }
        .onAppear(){
            posterManager.fetchPoster()
        }
        .toolbar {
            // Sammelposten hinzufügen
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
}

struct PosterRowView: View {
    let poster: PosterResponseDTO
    
    var body: some View {
        NavigationLink(destination: PosterDetailView(poster: poster)) {
            HStack(spacing: 5) {
                if let uiImage = UIImage(data: poster.image) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200) // Höhe einstellen
                }
                
                Text(poster.name)
                    .font(.headline)
            }
        }
    }
}


struct SammelpostenErstellenView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil // Optional Data für das Bild
    @StateObject private var posterManager = PosterManager() // MeetingManager als StateObject

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
        let resizedImageData = resizeAndCompressImageData(imageData: imageData, maxWidth: 32, maxHeight: 32, compressionQuality: 0.8)
            
        let newPoster = CreatePosterDTO(
            name: title,
            description: description,
            image: resizedImageData
        )

        let imageName = "example.jpg"
        let mimeType = "image/jpeg"
        
        //posterManager.createPoster(poster: newPoster)
        posterManager.createPoster(poster: newPoster)
        dismiss()
    }
}


#Preview {
    PostersMainView()
}
