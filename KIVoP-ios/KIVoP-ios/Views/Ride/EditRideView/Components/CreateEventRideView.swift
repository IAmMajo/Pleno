// This file is licensed under the MIT-0 License.
import SwiftUI

struct CreateEventRideView: View {
    @ObservedObject var viewModel: EditRideViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedOption: String?

    var body: some View {
        VStack {
            List {
                Section(header: Text("Event auswählen")){
                    Picker("", selection: $viewModel.selectedEventId) {
                        Text("Wählen Sie ein Event").tag(nil as UUID?)
                        ForEach(viewModel.events, id: \.id) { event in
                            Text(event.name)
                                .tag(event.id as UUID?)
                        }
                    }
                    .labelsHidden()
                    .accentColor(.gray)
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: viewModel.selectedEventId) { oldValue, newValue in
                        if newValue == nil {
                            // Wenn kein Event ausgewählt wurde, setzen Sie die Eventdetails auf nil
                            viewModel.eventDetails = nil
                        } else if let eventID = newValue {
                            viewModel.fetchEventDetails(eventID: eventID)
                            viewModel.fetchEventRides()
                        }
                    }
                }
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
                } else {
                    Text("Bitte ein Event auswählen.")
                }
                
                // Wenn ich nicht am ausgewählten teilnehme, hab ich die Möglichkeit dran teilzunehmen
                if let event = viewModel.events.first(where: { $0.id == viewModel.selectedEventId }) {
                    if event.myState == .present {
                        // Speichern freigeben
                    } else {
                        Text("Du hast dem ausgewählten Event nicht zugesagt, und kannst daher keine Fahrgemeinschaft anbieten.")
                            .padding(.horizontal)
                        Button(action: {
                            viewModel.participateEvent(eventId: viewModel.selectedEventId!)
                        }){
                            Text("Jetzt teilnehmen")
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
                
                if viewModel.eventRide?.myState != .driver {
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
                                if viewModel.rideDetail.startLatitude != 0 && viewModel.rideDetail.startLatitude != 0 {
                                    viewModel.getAddressFromCoordinates(latitude: viewModel.rideDetail.startLatitude, longitude: viewModel.rideDetail.startLongitude) { address in
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
                        DatePicker("Startzeit", selection: $viewModel.starts, displayedComponents: [.date, .hourAndMinute])
                    }
                    Section(header: Text("Auto und Sitzplätze")) {
                        HStack {
                            ZStack(alignment: .topLeading){
                                // Placeholder Text
                                if viewModel.vehicleDescription.isEmpty {
                                    Text("Beschreibung Auto")
                                        .foregroundColor(.gray)
                                        .padding(.top, 10)
                                        .padding(.leading, 4)
                                        .opacity(0.7)
                                }
                                
                                TextEditor(text: $viewModel.vehicleDescription)
                                    .foregroundColor(.black)
                                    .frame(minHeight: 50, maxHeight: .infinity)
                            }
                            
                            HStack {
                                // Picker für die Auswahl der freien Sitze
                                Picker("",selection: $viewModel.emptySeats) {
                                    Text("Freie Plätze").tag(nil as Int?).foregroundColor(.gray)
                                    ForEach(0..<100) { number in
                                        Text("\(number)").tag(number as Int?)
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
                            if viewModel.rideDescription.isEmpty {
                                Text("Beschreibung oder weitere Infos zu deiner Fahrt")
                                    .foregroundColor(.gray)
                                    .padding(.top, 7)
                                    .padding(.leading, 4)
                                    .opacity(0.7)
                                    .frame(height: 50)
                            }
                            
                            TextEditor(text: $viewModel.rideDescription)
                                .foregroundColor(.black)
                                .frame(minHeight: 50, maxHeight: .infinity)
                        }
                    }
                } else {
                    Text("Du bist bereits Fahrer bei diesem Event, und kannst keine weitere Fahrgemeinschaft anlegen.")
                        .foregroundColor(.red)
                }
            }
            .listSectionSpacing(5)
            .listStyle(.insetGrouped)
            .navigationTitle("Neue Event Fahrt")
        }
    }
}

extension DateFormatter {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    static let hourFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
