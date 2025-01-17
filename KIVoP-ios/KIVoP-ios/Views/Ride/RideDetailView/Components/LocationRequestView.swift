import SwiftUI
import MapKit

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
                    Text("Bitte überprüfe und bestätige die Adresse von der du abgeholt werden möchtest")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding()
                    
                    SelectRideLocationView(selectedLocation: $viewModel.requestedLocation)
                        .frame(width: 350, height: 450)
                        .cornerRadius(10)

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
                    
                    Text("Hiermit betsätigst du, dass du von dieser Adresse abgeholt werden möchtest und an dieser Fahrgemeinschaft teilnimmst")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .onChange(of: viewModel.requestedLocation) {
                    // Hier gibt es keinen Parameter, da es ein Binding ist
                    if let location = viewModel.requestedLocation {
                        viewModel.getAddressFromCoordinates(latitude: Float(location.latitude), longitude: Float(location.longitude)) { address in
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
                .onAppear(){
                    viewModel.requestedLocation = viewModel.startLocation
                }
            }
        }
    }
}
