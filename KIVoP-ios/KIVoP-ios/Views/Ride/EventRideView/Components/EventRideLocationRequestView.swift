// This file is licensed under the MIT-0 License.
import SwiftUI
import MapKit
import CoreLocation

// Komponente um seinen Standort für ein Event festzulegen
// Anders als bei den Specialrides wird es global in einem Event gesetzt und nicht einzeln
struct EventRideLocationRequestView: View {
    @ObservedObject var viewModel: EventRideViewModel
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
                    
                    if viewModel.editInterestEvent {
                        Button(action: {
                            viewModel.deleteInterestEventRide()
                            dismiss()
                        }){
                            Text("Interesse entfernen")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        Text("Hiermit bestätigst du, dass du von dieser Adresse abgeholt werden möchtest.")
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                // Wenn requestedLocation ist mit dem Wert in der Karte verknüpft.
                // Wenn sich der Standort auf der Karte ändert (auf Standort hinzufügen geklickt wird), wird dieser übernommen
                .onChange(of: viewModel.requestedLocation) {
                    // Hier gibt es keinen Parameter, da es ein Binding ist
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
                    // Wenn die Adresse fürs Event noch nicht festgelegt wurde, wird Interesse Requested
                    // Wenn bereits festgelegt wird nur die Location gepatcht
                    trailing: Button("Bestätigen") {
                        // Bestätigen-Aktion
                        viewModel.requestLat = Float(viewModel.requestedLocation!.latitude)
                        viewModel.requestLong = Float(viewModel.requestedLocation!.longitude)
                        if viewModel.editInterestEvent {
                            viewModel.patchInterestEventRide()
                        } else {
                            viewModel.requestInterestEventRide()
                        }
                        dismiss()
                    }
                )
                // Wenn ich noch keinen Standort für mich festgelegt habe, wird das Ziel des Events als Location genommen
                // Wenn ich schon einen habe, wird mein festgelegter Standort genutzt
                .onAppear(){
                    if viewModel.editInterestEvent && viewModel.interestedEvent != nil {
                        viewModel.requestedLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(viewModel.interestedEvent!.latitude), longitude: CLLocationDegrees(viewModel.interestedEvent!.longitude))
                    } else {
                        viewModel.requestedLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(viewModel.eventDetails?.latitude ?? 0), longitude: CLLocationDegrees(viewModel.eventDetails?.longitude ?? 0))
                    }
                }
            }
        }
    }
}
