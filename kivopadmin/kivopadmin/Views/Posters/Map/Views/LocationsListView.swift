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

struct LocationsListView: View {
    // locationViewModel als EnvironmentObject
    @EnvironmentObject private var locationViewModel: LocationsViewModel
    
    var body: some View {
        List {
            // Wenn der user auf der Karte einen Filter setzt, wird das hier berücksichtigt (Bsp: zeige alle Plakate, die noch nicht hängen)
            ForEach(locationViewModel.filteredPositions, id: \.position.id) { position in
                Button {
                    // bei einem Klick auf ein Listenelement wird dieses Plakat ausgewählt
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
                // auf der linken Seite, wenn vorhanden ein kleines Bild des Plakates
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

            Text(position.address) // Adresse
            Spacer()
            // Statustext in Abhängigkeit des Status
            Text(PosterHelper.getDateStatusText(position: position.position).text)
               .font(.caption)
               .foregroundStyle(PosterHelper.getDateStatusText(position: position.position).color)
        }
    }

    

}
