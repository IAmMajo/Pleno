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

// View zum erstellen von EventRides (Wird in der NewRideView angezeigt)
struct CreateEventRideView: View {
    @ObservedObject var viewModel: EditRideViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedOption: String?

    var body: some View {
        VStack {
            List {
                // Event auswählen, zudem eine Fahrt angelegt werden soll
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
                // Alle Infos zum ausgewählten Event
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
                                    viewModel.rideManager.getAddressFromCoordinates(latitude: eventDetails.latitude, longitude: eventDetails.longitude) { address in
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
                
                // Wenn der Nutzer noch nicht am Event teilnimmt, muss dieser erst teilnehmen, bevor er eine Fahrt zu dem Event erstellen kann
                if let event = viewModel.events.first(where: { $0.id == viewModel.selectedEventId }) {
                    if event.myState == .present {
                        // Speichern freigeben
                    } else {
                        Text("Du hast dem ausgewählten Event nicht zugesagt, und kannst daher keine Fahrgemeinschaft anbieten.")
                            .padding(.horizontal)
                        Button(action: {
                            viewModel.participateEvent(eventID: viewModel.selectedEventId!)
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
                
                // Wenn ich noch nicht Fahrer bei einer Fahrt in dem Event bin, kann ich nun die Infos zur Fahrt ausfüllen
                // Ansonsten wird eine Meldung angezeigt, dass man bereits eine Fahrt zu diesem Event hat, und es ist nicht möglich eine weitere Fahrt anzulegen
                if viewModel.eventRide?.myState != .driver {
                    Section(header: Text("Startort")){
                        HStack{
                            // Karte, die die ausgewählte Position anzeigt.
                            // Beim drücken auf die Karte, wird ein sheet zum Auswählen der Startposition geöffnet
                            Button(action: {
                                DispatchQueue.main.async {
                                    viewModel.showingLocation.toggle()
                                }
                            }) {
                                // Map, die nur die Position anzeigt
                                RideLocationView(selectedLocation: $viewModel.location)
                                    .cornerRadius(10)
                                    .frame(width: 100, height: 150)
                                    .padding(.top, -11)
                                    .padding(.bottom, -11)
                                    .padding(.leading, -20)
                            }
                            VStack{
                                // Addresse
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
                            // Berechnen der Adresse
                            .onAppear {
                                if viewModel.rideDetail.startLatitude != 0 && viewModel.rideDetail.startLatitude != 0 {
                                    viewModel.rideManager.getAddressFromCoordinates(latitude: viewModel.rideDetail.startLatitude, longitude: viewModel.rideDetail.startLongitude) { address in
                                        if let address = address {
                                            viewModel.address = address
                                        }
                                    }
                                }
                            }
                            // Aktualisieren der Koordinaten und der Adresse vom sheet zur Standortauswahl
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
                                // Standortauswahl
                                SelectRideLocationView(selectedLocation: $viewModel.location)
                            }
                        }
                    }
                    // Abfahrtszeit
                    Section(header: Text("Abfahrtszeit")){
                        DatePicker("Startzeit", selection: $viewModel.starts, displayedComponents: [.date, .hourAndMinute])
                    }
                    // Informationen zum AUto + Sitzplätze
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
                                // Auch 0 Plätze sind möglich
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
                    // Optionale Hinweise für Mitfahrer
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

// Um die Zeit vom Event so anzuzeigen als wäre es ein richtiger Picker (Wie im Prototyp)
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
