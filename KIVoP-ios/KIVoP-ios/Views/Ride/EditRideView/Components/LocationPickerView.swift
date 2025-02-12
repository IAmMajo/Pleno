// This file is licensed under the MIT-0 License.
import SwiftUI
import MapKit

// Komponente für die SonderFahrten
// Zeigt die Standort Logik an
struct LocationPickerView: View {
    @ObservedObject var viewModel: EditRideViewModel
    
    var body: some View {
        Section(header: Text("Startort")) {
            HStack{
                Button(action: {
                    // Öffnet das Sheet zur Standortauswahl
                    DispatchQueue.main.async {
                        viewModel.showingLocation.toggle()
                    }
                }) {
                    // Feste Map zur Anzeige des Standorts
                    RideLocationView(selectedLocation: $viewModel.location)
                        .cornerRadius(10)
                        .frame(width: 100, height: 150)
                        .padding(.top, -11)
                        .padding(.bottom, -11)
                        .padding(.leading, -20)
                }
                VStack{
                    // Adresse
                    if(viewModel.address != ""){
                        Text(viewModel.address)
                            .padding(.top, 10)
                    } else {
                        Text("Bitte wählen Sie einen Startort aus.")
                            .padding(.top, 10)
                    }
                    Spacer()
                    // Koordinaten
                    if(viewModel.location != nil){
                        Divider()
                            .background(Color.gray)
                            .padding(.bottom, 10)
                        Text("\(viewModel.location?.latitude ?? 0.0), \(viewModel.location?.longitude ?? 0.0)")
                            .padding(.bottom, 10)
                    }
                }
                // OnAppear wird die Adresse aus den Koordinaten berechnet
                .onAppear {
                    if viewModel.rideDetail.startLatitude != 0 && viewModel.rideDetail.startLatitude != 0 {
                        viewModel.rideManager.getAddressFromCoordinates(latitude: viewModel.rideDetail.startLatitude, longitude: viewModel.rideDetail.startLongitude) { address in
                            if let address = address {
                                viewModel.address = address
                            }
                        }
                    }
                }
                // Zeigt das Sheet an zur Auswahl des Startortes
                .sheet(isPresented: $viewModel.showingLocation, onDismiss: {
                    if let location = viewModel.location {
                        let latitude = Float(location.latitude)
                        let longitude = Float(location.longitude)
                        
                        viewModel.rideManager.getAddressFromCoordinates(latitude: latitude, longitude: longitude) { address in
                            if let address = address {
                                viewModel.address = address
                            }
                        }
                    }

                }) {
                    // Sheet Inhalt
                    SelectRideLocationView(selectedLocation: $viewModel.location)
                }
            }
        }
        // 1:1 wie oben, aber für dstLocation
        Section(header: Text("Zielort")) {
            HStack{
                Button(action: {
                    DispatchQueue.main.async {
                        viewModel.showingDstLocation.toggle()
                    }
                }) {
                    RideLocationView(selectedLocation: $viewModel.dstLocation)
                        .cornerRadius(10)
                        .frame(width: 100, height: 150)
                        .padding(.top, -11)
                        .padding(.bottom, -11)
                        .padding(.leading, -20)
                        .disabled(true)
                }
                VStack{
                    if(viewModel.dstAddress != ""){
                        Text(viewModel.dstAddress)
                            .padding(.top, 10)
                    } else {
                        Text("Bitte wählen Sie einen Zielort aus.")
                            .padding(.top, 10)
                    }
                    Spacer()
                    if(viewModel.dstLocation != nil){
                        Divider()
                            .background(Color.gray)
                            .padding(.bottom, 10)
                        Text("\(viewModel.dstLocation?.latitude ?? 0.0), \(viewModel.dstLocation?.longitude ?? 0.0)")
                            .padding(.bottom, 10)
                    }
                }
                .onAppear {
                    if viewModel.rideDetail.destinationLatitude != 0 && viewModel.rideDetail.destinationLongitude != 0 {
                        viewModel.rideManager.getAddressFromCoordinates(latitude: viewModel.rideDetail.destinationLatitude, longitude: viewModel.rideDetail.destinationLongitude) { address in
                            if let address = address {
                                viewModel.dstAddress = address
                            }
                        }
                    }
                }
                .sheet(isPresented: $viewModel.showingDstLocation, onDismiss: {
                    if let dstLocation = viewModel.dstLocation {
                        let latitude = Float(dstLocation.latitude)
                        let longitude = Float(dstLocation.longitude)
                        
                        viewModel.rideManager.getAddressFromCoordinates(latitude: latitude, longitude: longitude) { address in
                            if let address = address {
                                viewModel.dstAddress = address
                            }
                        }
                    }
                }) {
                    // Sheet Inhalt
                    SelectRideLocationView(selectedLocation: $viewModel.dstLocation)
                }
            }
        }
    }
}
