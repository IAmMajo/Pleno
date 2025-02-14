// This file is licensed under the MIT-0 License.
import SwiftUI
import MapKit

// Komponente um bei einer Anfrage zu einer Fahrt seinen Standort zu bestätigen
// Erscheint als Sheet
struct SpecialRideLocationRequestView: View {
    @ObservedObject var viewModel: RideDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            // Den gesamten Hintergrund grau hinterlegen (Damit alles so aussieht als wäre es eine Liste)
            ZStack {
                (colorScheme == .dark ? Color.black.opacity(0.1) : Color.gray.opacity(0.1))
                            .edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Bitte überprüfe und bestätige die Adresse von der du abgeholt werden möchtest")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding()
                    
                    // Karte um Standort auszuwählen
                    // Zu beginn wird der Standort des Fahrers angezeigt
                    SelectRideLocationView(selectedLocation: $viewModel.requestedLocation)
                        .frame(width: 350, height: 400)
                        .cornerRadius(10)

                    // Adresse für den ausgewählten Standort
                    List {
                        Section{
                            Text(viewModel.requestedAdress.isEmpty ? "Standort auswählen" : viewModel.requestedAdress)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text("\(viewModel.requestedLocation?.latitude ?? 0.0), \(viewModel.requestedLocation?.longitude ?? 0.0)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, -10)
                    }
                    .scrollDisabled(true)
                    
                    Text("Hiermit bestätigst du, dass du von dieser Adresse abgeholt werden möchtest und an dieser Fahrgemeinschaft teilnimmst")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                // Wenn requestedLocation ist mit dem Wert in der Karte verknüpft.
                // Wenn sich der Standort auf der Karte ändert (auf Standort hinzufügen geklickt wird), wird dieser übernommen
                .onChange(of: viewModel.requestedLocation) {
                    if let location = viewModel.requestedLocation {
                        viewModel.rideManager.getAddressFromCoordinates(latitude: Float(location.latitude), longitude: Float(location.longitude)) { address in
                            if let address = address {
                                viewModel.requestedAdress = address
                            }
                        }
                    }
                }

                .navigationBarTitle("Adresse bestätigen", displayMode: .inline)
                .navigationBarItems(
                    leading: Button("Abbrechen") {
                        // Aktion zum Schließen
                        dismiss()
                    },
                    trailing: Button("Bestätigen") {
                        // Bestätigen-Aktion
                        viewModel.requestLat = Float(viewModel.requestedLocation!.latitude)
                        viewModel.requestLong = Float(viewModel.requestedLocation!.longitude)
                        viewModel.requestRide()
                        dismiss()
                    }
                )
                // Wenn das sheet erscheint, wird der Standort auf den vom Fahrer gesetzt
                .onAppear(){
                    viewModel.requestedLocation = viewModel.startLocation
                }
            }
        }
    }
}
