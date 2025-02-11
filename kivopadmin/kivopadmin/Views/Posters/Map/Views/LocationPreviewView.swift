
import SwiftUI
import PosterServiceDTOs

struct LocationPreviewView: View {
    // locationViewModel als EnvironmentObject
    @EnvironmentObject private var locationViewModel: LocationsViewModel
    
    // Plakatpositon mit Adresse wird beim Aufruf übergeben
    let position: PosterPositionWithAddress
    
    var body: some View {
        ZStack{
            HStack(){
                // Auf der linken Seite eine kleine Ansicht des Bildes
                imageSection
                VStack(alignment: .leading, spacing: 16.0){
                    titleSection
                }
                // Zwei Buttons auf der rechten Seite ("Details" und "nächstes")
                buttonsSection
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThickMaterial))
            .cornerRadius(10)
            HStack{
                // backButton zum schließen der Preview
                backButton.offset(x: -35, y: -75)
                Spacer()
            }
        }

    }
}


extension LocationPreviewView {
    private var imageSection: some View {
        Group {
            if let imageData = position.image, // Unwrap optional Data
               let uiImage = UIImage(data: imageData) { // Erzeuge ein UIImage aus Data
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                    .frame(maxWidth: 100, maxHeight: 100)
            } else {
                ZStack {} // Leere View, wenn kein Bild verfügbar
            }
        }
    }

    
    private var titleSection: some View {
        VStack(alignment: .leading){
            // Adresse als Titel
            Text(position.address).font(.title2).fontWeight(.bold)
            
            // StatusText in Abhängigkeit des Status -> Bsp: "hängt noch nicht"
            Text(PosterHelper.getDateStatusText(position: position.position).text)
               .font(.headline)
               .foregroundStyle(PosterHelper.getDateStatusText(position: position.position).color)
            
            // Wenn das Plakat noch nicht abgehangen wurde, wird das Ablaufdatum angezeigt
            if position.position.status != .takenDown {
                Text("Ablaufdatum: \(DateTimeFormatter.formatDate(position.position.expiresAt))")
            }
        }
        .padding(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var buttonsSection: some View {
        VStack(spacing: 8){
            // Details-Button
            Button{
                locationViewModel.sheetPosition = position
            }label:{
                Text("Details").font(.headline).frame(width: 125, height: 35)
            }.buttonStyle(.borderedProminent)
            
            // Button, der den User zum nächsten Plakat führt
            Button{
                locationViewModel.nextButtonPressed()
            }label:{
                Text("Nächste").font(.headline).frame(width: 125, height: 35)
            }.buttonStyle(.bordered)

        }

    }
    // Backbutton, mit einem "X"
    private var backButton: some View {
        Button {
            locationViewModel.selectedPosterPosition = nil
        } label: {
            Image(systemName: "xmark").font(.headline).padding(16).foregroundColor(.primary).background(.thinMaterial).cornerRadius(10).shadow(radius: 4).padding()
        }
    }
}

