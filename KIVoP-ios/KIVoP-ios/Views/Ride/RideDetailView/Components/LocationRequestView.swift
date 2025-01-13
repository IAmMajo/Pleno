import SwiftUI

struct LocationRequestView: View {
    @ObservedObject var viewModel: RideDetailViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                // grauer Hintergrund
                Color.gray.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Adresse bestätigen")
                        .font(.headline)
                        .padding()
                    Text("Karte zum Standort auswählen wird noch hinzugefügt.")
                    Text("Momentan Base Koordinaten 0,0")
                }
                .navigationBarTitle("Adresse bestätigen", displayMode: .inline)
                .navigationBarItems(
                    leading: Button("Abbrechen") {
                        // Aktion zum Schließen
                        dismiss()
                    },
                    trailing: Button("Bestätigen") {
                        // Bestätigen-Aktion
                        viewModel.requestRide()
                        dismiss()
                    }
                )
            }
        }
    }
}
