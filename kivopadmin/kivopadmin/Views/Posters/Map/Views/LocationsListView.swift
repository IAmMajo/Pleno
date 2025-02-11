
import SwiftUI
import PosterServiceDTOs

struct LocationsListView: View {
    @EnvironmentObject private var locationViewModel: LocationsViewModel
    
    var body: some View {
        List {
            ForEach(locationViewModel.filteredPositions, id: \.position.id) { position in
                Button {
                    locationViewModel.showNextLocation(location: position)
                } label: {
                    listRowView(position: position)
                }
                .padding(.vertical, 5)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())

    }
}

extension LocationsListView {
    
    private func listRowView(position: PosterPositionWithAddress) -> some View {
        HStack {
            Group {
                if let imageData = position.image, // Unwrap optional Data
                   let uiImage = UIImage(data: imageData) { // Erzeuge ein UIImage aus Data
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                } else {
                    Color.clear // Platzhalter für leere Bilder
                }
            }
            .frame(width: 45, height: 45) // Feste Breite und Höhe für das Bild

            Text(position.address)
            Spacer()
            Text(PosterHelper.getDateStatusText(position: position.position).text)
               .font(.caption)
               .foregroundStyle(PosterHelper.getDateStatusText(position: position.position).color)
        }
    }

    

}
