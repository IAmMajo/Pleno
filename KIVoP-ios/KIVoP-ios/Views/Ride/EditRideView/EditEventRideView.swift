import SwiftUI
import MapKit

struct EditEventRideView: View {
    @StateObject var viewModel: EditRideViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            List {
                if let eventDetails = viewModel.eventDetails {
                    Section(header: Text("Details zum Event")) {
                        Text(eventDetails.name)
                        Text(eventDetails.description ?? "Es gibt keine Beschreibung zu diesem Event.")
                        HStack{
                            Text("Startzeit")
                            Spacer()
                            Text(DateFormatter.dateFormatter.string(from: eventDetails.starts))
                                .padding(8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
                            Text(DateFormatter.hourFormatter.string(from: eventDetails.starts))
                                .padding(8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
                        }
                        Text(viewModel.dstAddress)
                            .onAppear{
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    viewModel.getAddressFromCoordinates(latitude: eventDetails.latitude, longitude: eventDetails.longitude) { address in
                                        if let address = address {
                                            viewModel.dstAddress = address
                                        }
                                    }
                                }
                            }
                        Text("\(eventDetails.latitude), \(eventDetails.longitude)")
                    }
                }
                
                Section(header: Text("Startort")){
                    HStack{
                        Button(action: {
                            DispatchQueue.main.async {
                                viewModel.showingLocation.toggle()
                            }
                        }) {
                            RideLocationView(selectedLocation: $viewModel.location)
                                .cornerRadius(10)
                                .frame(width: 100, height: 150)
                                .padding(.top, -11)
                                .padding(.bottom, -11)
                                .padding(.leading, -20)
                        }
                        VStack{
                            if(viewModel.address != ""){
                                Text(viewModel.address)
                                    .padding(.top, 10)
                            } else {
                                Text("Bitte wählen Sie einen Startort aus.")
                                    .padding(.top, 10)
                            }
                            Spacer()
                            if(viewModel.location != nil){
                                Divider()
                                    .background(Color.gray)
                                    .padding(.bottom, 10)
                                Text("\(viewModel.location?.latitude ?? 0.0), \(viewModel.location?.longitude ?? 0.0)")
                                    .padding(.bottom, 10)
                            }
                        }
                        .onAppear {
                            if viewModel.eventRideDetail.latitude != 0 && viewModel.eventRideDetail.longitude != 0 {
                                viewModel.getAddressFromCoordinates(latitude: viewModel.eventRideDetail.latitude, longitude: viewModel.eventRideDetail.longitude) { address in
                                    if let address = address {
                                        viewModel.address = address
                                    }
                                }
                            }
                        }
                        .sheet(isPresented: $viewModel.showingLocation, onDismiss: {
                            if let location = viewModel.location {
                                let latitude = Float(location.latitude)
                                let longitude = Float(location.longitude)
                                
                                viewModel.getAddressFromCoordinates(latitude: latitude, longitude: longitude) { address in
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
                Section(header: Text("Abfahrtszeit")){
                    DatePicker("Startzeit", selection: $viewModel.eventRideDetail.starts, displayedComponents: [.date, .hourAndMinute])
                }
                Section(header: Text("Auto und Sitzplätze")) {
                    HStack {
                        ZStack(alignment: .topLeading){
                            // Placeholder Text
                            if viewModel.eventRideDetail.vehicleDescription == "" {
                                Text("Beschreibung Auto")
                                    .foregroundColor(.gray)
                                    .padding(.top, 10)
                                    .padding(.leading, 4)
                                    .opacity(0.7)
                            }
                            
                            TextEditor(text: Binding(
                                get: { viewModel.eventRideDetail.vehicleDescription ?? "" },
                                set: { viewModel.eventRideDetail.vehicleDescription = $0 }
                            ))
                                .foregroundColor(.black)
                                .frame(minHeight: 50, maxHeight: .infinity)
                        }
                        
                        HStack {
                            // Picker für die Auswahl der freien Sitze
                            Picker("",selection: $viewModel.eventRideDetail.emptySeats) {
                                ForEach(0..<100) { number in
                                    Text("\(number)").tag(UInt8(number))
                                }
                            }
                            .padding(.top, -10)
                            .foregroundColor(.gray)
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.4)
                    }
                }
                Section(header: Text("Hinweise")){
                    ZStack(alignment: .topLeading) {
                        // Placeholder Text
                        if viewModel.eventRideDetail.description == "" {
                            Text("Beschreibung oder weitere Infos zu deiner Fahrt")
                                .foregroundColor(.gray)
                                .padding(.top, 7)
                                .padding(.leading, 4)
                                .opacity(0.7)
                                .frame(height: 50)
                        }
                        
                        TextEditor(text: Binding(
                            get: { viewModel.eventRideDetail.description ?? "" },
                            set: { viewModel.eventRideDetail.description = $0 }
                        ))
                            .foregroundColor(.black)
                            .frame(minHeight: 50, maxHeight: .infinity)
                    }
                }
            }
            .listSectionSpacing(5)
            .listStyle(.insetGrouped)
            .navigationTitle(viewModel.eventRideDetail.eventName)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .onAppear(){
                viewModel.fetchEventDetails(eventID: viewModel.eventRideDetail.eventID)
            }
            .toolbar{
                // Speichern Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if viewModel.isFormValid {
                            viewModel.selectedOption = "EventFahrt"
                            viewModel.saveEditedRide()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                dismiss()
                            }
                        } else {
                            viewModel.showSaveAlert = true
                        }
                    }) {
                        Text("Speichern")
                            .font(.body)
                    }
                    .alert(isPresented: $viewModel.showSaveAlert) {
                        Alert(
                            title: Text("Fehler"),
                            message: Text("Bitte füllen Sie alle Felder aus. Das Startdatum muss außerdem in der Zukunft liegen."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
                // Zurück Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        viewModel.showDismissAlert = true
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Zurück")
                                .font(.body)
                        }
                    }
                    .alert(isPresented: $viewModel.showDismissAlert) {
                        Alert(
                            title: Text("Möchtest du wirklich zurück?"),
                            message: Text("Alle nicht gespeicherten Änderungen gehen verloren!"),
                            primaryButton: .default(Text("Nein")),
                            secondaryButton: .destructive(Text("Ja").foregroundColor(.red), action: {
                                dismiss()
                            })
                        )
                    }
                }
            }
        }
    }
}
