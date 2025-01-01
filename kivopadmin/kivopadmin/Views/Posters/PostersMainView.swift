import SwiftUI
import PosterServiceDTOs
import PhotosUI

struct PostersMainView: View {
   @Environment(\.dismiss) var dismiss
   @State private var isPostenSheetPresented = false // Zustand für das Sheet
   
   @State private var posters: [Poster] = mockPosters
   @State private var postersFiltered: [Poster] = []
   
   @StateObject private var postersViewModel = PostersViewModel()
   
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
            ZStack {
                ZStack(alignment: .top) {
                    if !posters.isEmpty {
                        
                        List {
                            ForEach(postersViewModel.filteredPosters.indices, id: \.self) { index in
                                let poster = postersViewModel.filteredPosters[index]
                                NavigationLink(destination: PosterDetailView(poster: poster).navigationTitle(poster.name)) {
                                    HStack {
                                        VStack {
                                            Text(poster.name)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            if let expirationPosition = postersViewModel.posterExpiresPositions[poster.id!] {
                                                Text("\(DateTimeFormatter.formatDate(expirationPosition.expiresAt))")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(.callout)
                                                    .foregroundStyle(getDateColor(status: expirationPosition.status))
                                            } else {
                                                Text("No expiration date")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(.callout)
                                            }
                                        }
                                        Spacer()
                                        if(postersViewModel.posterExpiresPositions[poster.id!]?.status != .notDisplayed){
                                            if (numberOfPostersToHang[index] != 0) {
                                                Image(systemName: "\(numberOfPostersToHang[index]).circle.fill")
                                                    .resizable()
                                                    .frame(maxWidth: 22, maxHeight: 22)
                                                    .aspectRatio(1, contentMode: .fit)
                                                    .foregroundStyle(.blue)
                                                    .padding(.trailing, 5)
                                            }
                                        }
                                        if(postersViewModel.posterExpiresPositions[poster.id!]?.status == .expired){
                                            Image(systemName: "2.circle.fill")
                                                .resizable()
                                                .frame(maxWidth: 22, maxHeight: 22)
                                                .aspectRatio(1, contentMode: .fit)
                                                .foregroundStyle(.red)
                                        }
                                        
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .padding(.top, 20)
                        .refreshable {
                        }
                        
                        Picker("Termine", selection: $postersViewModel.selectedTab) {
                            Text("Aktuell").tag(0)
                            Text("Archiviert").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal) .padding(.bottom, 10)
                        .background(.white)
                        
                    } else {
                        ContentUnavailableView {
                        }
                    }
                    
                }
                .navigationTitle("Plakate")
                .navigationBarTitleDisplayMode(.large)
                
                //         .task(id: selectedVoting) {
                //            if let voting = selectedVoting {
                //               hasVoted = VotingStateTracker.hasVoted(for: voting.id)
                //               await loadVotingResults(voting: voting)
                //            }
                //         }
                .onAppear {
                    Task {
                        
                    }
                }
                .overlay {
                    if isLoading {
                        ProgressView("Loading...")
                    } else if let error = error {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                    }
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
            .background(Color(UIColor.secondarySystemBackground))
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Suchen")
            .onChange(of: searchText) {
                Task {
                    if searchText.isEmpty {
                        postersFiltered = posters
                    } else {
                        postersFiltered = posters.filter { poster in
                            return poster.name.contains(searchText)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isPostenSheetPresented) {
            SammelpostenErstellenView()
        }
    }
}


struct SammelpostenErstellenView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil // Optional Data für das Bild

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
            description: description.isEmpty ? nil : description,
            image: imageData
        )

        print("Sammelposten erstellt: \(newPoster)")
        dismiss()
    }
}


#Preview {
    PostersMainView()
}
