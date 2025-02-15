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
import AuthServiceDTOs

struct LocationDetailView: View {
    // locationViewModel als EnvironmentObject
    @EnvironmentObject private var locationViewModel: LocationsViewModel
    
    // Plakatposition mit Adresse wird beim Aufruf übergeben
    let position: PosterPositionWithAddress
    
    // alle User werden beim Aufruf übergeben
    var users: [UserProfileDTO]
    
    // der Sammelposten, zu dem die Plakatposition gehört, wird beim Aufruf übergeben
    var poster: PosterResponseDTO
    
    // Ablaufdatum
    @State private var date: Date = Date()
    
    // Bool Variable für Confirmation Alert
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in // Hinzufügen des ScrollViewReaders
                ScrollView {
                    VStack {
                        // Bild des Plakates
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
            // Beim Aufruf der View wird das Verfallsdatum direkt der Variable date zugewiesen
            date = position.position.expiresAt
        }
    }


}


extension LocationDetailView {
    
    // Hier wird das Bild der Plakatposition angezeigt
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
    
    // Die Überschrift einer Plakatposition ist die Adresse
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8){
            Text(position.address).font(.largeTitle).fontWeight(.semibold)
        }
    }
    
    private var bodySection: some View {
        VStack(alignment: .leading, spacing: 8){
            // Statustext -> Bsp: "hängt noch nicht"
            Text(PosterHelper.getDateStatusText(position: position.position).text)
               .font(.headline)
               .foregroundStyle(PosterHelper.getDateStatusText(position: position.position).color)
            
            // Progressbar zur Anzeige des Status
            ProgressBarView(position: position.position)
            
            // Link, um die Plakatposition zu bearbeiten
            NavigationLink(destination: EditPosterPosition(poster: poster,posterPosition: position.position, selectedUsers: position.position.responsibleUsers.map { $0.id }, date: $date)){
                Text("Plakatposition bearbeiten")
            }.padding(.vertical)
            Divider()
            
            // Ablaufdatum anzeigen
            HStack{
                Text("Ablaufdatum:").font(.headline)
                Spacer()
                Text(DateTimeFormatter.formatDate(position.position.expiresAt)).font(.headline)
            }.padding(.vertical, 10)
            
            Divider()
            VStack(alignment: .leading){
                // Verantwortliche Personen anzeigen
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
        // alert zum Bestätigen des Löschens
        .alert("Plakatposition löschen?", isPresented: $showDeleteConfirmation) {
            Button("Abbrechen", role: .cancel) {
                // Benutzer hat das Löschen abgebrochen
            }
            Button("Löschen", role: .destructive) {
                // Benutzer hat bestätigt, die Position zu löschen
                locationViewModel.deleteSinglePosterPosition(
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


