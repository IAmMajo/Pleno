
import SwiftUI
import PosterServiceDTOs
import AuthServiceDTOs

struct LocationDetailView: View {
    @EnvironmentObject private var locationViewModel: LocationsViewModel
    
    let position: PosterPositionWithAddress
    var users: [UserProfileDTO]
    var poster: PosterResponseDTO
    @State private var date: Date = Date()
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in // Hinzufügen des ScrollViewReaders
                ScrollView {
                    VStack {
                        imageSection
                            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)

                        VStack(alignment: .leading, spacing: 16) {
                            titleSection
                            bodySection
                                .id("bodySection") // Die View scrollt beim Aufruf direkt runter
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        deleteSection
                    }
                }
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
                .onAppear {
                    // Automatisch zum definierten Bereich scrollen
                    withAnimation {
                        proxy.scrollTo("bodySection", anchor: .top)
                    }
                }
            }
        }
        .onAppear {
            date = position.position.expiresAt
        }
    }


}


extension LocationDetailView {
    private var imageSection: some View {
        Group {
            if let imageData = position.image, // Unwrap optional Data
               let uiImage = UIImage(data: imageData) { // Erzeuge ein UIImage aus Data
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                    .frame(width: .infinity)
            } else {
                EmptyView()
            }
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8){
            Text(position.address).font(.largeTitle).fontWeight(.semibold)
        }
    }
    
    private var bodySection: some View {
        VStack(alignment: .leading, spacing: 8){
            Text(PosterHelper.getDateStatusText(position: position.position).text)
               .font(.headline)
               .foregroundStyle(PosterHelper.getDateStatusText(position: position.position).color)
            ProgressBarView(position: position.position)
            NavigationLink(destination: EditPosterPosition(poster: poster,selectedUsers: position.position.responsibleUsers.map { $0.id }, posterPosition: position.position, date: $date)){
                Text("Plakatposition bearbeiten")
            }.padding(.vertical)
            Divider()
            HStack{
                Text("Ablaufdatum:").font(.headline)
                Spacer()
                Text(DateTimeFormatter.formatDate(position.position.expiresAt)).font(.headline)
            }.padding(.vertical, 10)
            
            Divider()
            VStack(alignment: .leading){

                if position.position.responsibleUsers.count == 1 {
                    Text("Verantwortliche Person").font(.headline)
                } else if position.position.responsibleUsers.count > 1 {
                    Text("Verantwortliche Personen").font(.headline)
                }

                

                ForEach(position.position.responsibleUsers, id: \.id) { user in
                    Text(user.name)
                        .font(.body)
                        .foregroundColor(.primary)

                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.1)))
                }
            }.padding(.vertical, 10)

        }

    }
    private var deleteSection: some View {
        Button {
            // Zeige den Bestätigungsdialog an
            showDeleteConfirmation = true
        } label: {
            Text("Löschen")
                .font(.headline)
                .frame(maxWidth: .infinity) // Volle Breite und feste Höhe
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
        }
        .padding()
        .buttonStyle(.bordered)
        .alert("Plakatposition löschen?", isPresented: $showDeleteConfirmation) {
            Button("Abbrechen", role: .cancel) {
                // Benutzer hat das Löschen abgebrochen
            }
            Button("Löschen", role: .destructive) {
                // Benutzer hat bestätigt, die Position zu löschen
                locationViewModel.deleteSignlePosterPosition(
                    positionId: position.position.id
                ) {
                    locationViewModel.fetchPosterPositions(poster: poster)
                    locationViewModel.sheetPosition = nil // Ansicht schließen
                    
                }
            }
        } message: {
            Text("Diese Aktion kann nicht rückgängig gemacht werden.")
        }
    }
    
    
    private var backButton: some View {
        Button {
            locationViewModel.sheetPosition = nil
        } label: {
            Image(systemName: "xmark").font(.headline).padding(16).foregroundColor(.primary).background(.thinMaterial).cornerRadius(10).shadow(radius: 4).padding()
        }
    }

}


