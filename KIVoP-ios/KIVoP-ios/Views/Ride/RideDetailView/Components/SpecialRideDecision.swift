// This file is licensed under the MIT-0 License.
import SwiftUI

struct SpecialRideDecision: View {
    @ObservedObject var viewModel: RideDetailViewModel
    @ObservedObject var rideViewModel: RideViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        // Logik für den Button in der SpecialRideDetailView
        // Als Fahrer - Fahrt löschen
        // Als Mitfahrer - Mitfahrt stornieren
        // sonst - Mitfahren beantragen
        if (viewModel.rideDetail.isSelfDriver){
            Button(action: {
                viewModel.showDeleteRideAlert = true
            }) {
                Text("Fahrt löschen")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .buttonStyle(PlainButtonStyle())
            // Fahrer löscht die ganze Fahrgemeinschaft
            .alert(isPresented: $viewModel.showDeleteRideAlert) {
                Alert(
                    title: Text("Bestätigung"),
                    message: Text("Möchten Sie die Fahrt wirklich löschen?"),
                    primaryButton: .destructive(Text("Löschen")) {
                        // Aktion zum Löschen der Fahrt
                        viewModel.deleteRide()
                        viewModel.showDeleteRideAlert = false
                        rideViewModel.fetchRides()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            dismiss()
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        } else {
            if (viewModel.rider?.accepted == false){
                // Anfrage löschen
                Button(action: {
                    viewModel.showDeleteRideRequest = true
                }) {
                    Text("Anfrage zurücknehmen")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .buttonStyle(PlainButtonStyle())
                // Request löschen
                .alert(isPresented: $viewModel.showDeleteRideRequest) {
                    Alert(
                        title: Text("Bestätigung"),
                        message: Text("Möchten Sie die Anfrage wirklich löschen?"),
                        primaryButton: .destructive(Text("Löschen")) {
                            // Aktion zum Löschen der Fahrt
                            viewModel.deleteRideRequestedSeat(rider: viewModel.rider!)
                            viewModel.fetchRideDetails()
                            viewModel.showDeleteRideRequest = false
                        },
                        secondaryButton: .cancel()
                    )
                }
            } else if (viewModel.rider?.accepted == true){
                // Mitfahrt löschen
                Button(action: {
                    viewModel.showRiderDeleteRequest = true
                }) {
                    Text("Mitfahrt löschen")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .buttonStyle(PlainButtonStyle())
                // Nachdem Mitfahrer angenommen wurde, storniere ich die Mitfahrt
                .alert(isPresented: $viewModel.showRiderDeleteRequest) {
                    Alert(
                        title: Text("Bestätigung"),
                        message: Text("Möchten Sie Ihren Platz wirklich wieder freigeben?"),
                        primaryButton: .destructive(Text("Freigeben")) {
                            // Aktion zum Löschen der Fahrt
                            viewModel.deleteRideRequestedSeat(rider: viewModel.rider!)
                            viewModel.fetchRideDetails()
                            viewModel.showRiderDeleteRequest = false
                        },
                        secondaryButton: .cancel()
                    )
                }
            } else {
                // Anfrage stellen
                Button(action: {
                    viewModel.showLocationRequest = true
                }) {
                    Text("Mitfahrt anfragen")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}
