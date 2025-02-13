// This file is licensed under the MIT-0 License.
import SwiftUI

struct EditSpecialRideView: View {
    @ObservedObject var viewModel: EditRideViewModel
    @Environment(\.dismiss) private var dismiss

    // View zum Bearbeiten der SpecialRides
    // Funktioniert wie die CreateView, abgesehen von:
    // - Die Sitzplätze können nicht unter die Anzahl an bereits besetzten Plätzen gesetzt werden.
    var body: some View {
        VStack {
            List {
                Section(header: Text("Details der Fahrt")) {
                    TextField("Name der Fahrt", text: $viewModel.rideDetail.name)
                    ZStack(alignment: .topLeading) {
                        // Placeholder Text
                        if viewModel.rideDetail.description == "" {
                            Text("Beschreibung oder weitere Infos zu deiner Fahrt")
                                .foregroundColor(.gray)
                                .padding(.top, 7)
                                .padding(.leading, 4)
                                .opacity(0.7)
                                .frame(height: 50)
                        }
                        
                        TextEditor(text: Binding(
                            get: { viewModel.rideDetail.description ?? "" },
                            set: { viewModel.rideDetail.description = $0 }
                        ))
                        .foregroundColor(.black)
                        .frame(minHeight: 50, maxHeight: .infinity)

                    }
                    .padding(.leading, -3)
                    DatePicker("Startzeit", selection: $viewModel.rideDetail.starts, displayedComponents: [.date, .hourAndMinute])
                }
                
                // Komponente zum anzeigen der Standortdetails und auswählen von neuen Standorten
                LocationPickerView(viewModel: viewModel)
                
                Section(header: Text("Auto und Sitzplätze")) {
                    HStack {
                        ZStack(alignment: .topLeading){
                            // Placeholder Text
                            if viewModel.rideDetail.vehicleDescription == "" {
                                Text("Beschreibung Auto")
                                    .foregroundColor(.gray)
                                    .padding(.top, 10)
                                    .padding(.leading, 4)
                                    .opacity(0.7)
                            }
                            
                            TextEditor(text: Binding(
                                get: { viewModel.rideDetail.vehicleDescription ?? "" },
                                set: { viewModel.rideDetail.vehicleDescription = $0 }
                            ))
                                .foregroundColor(.black)
                                .frame(minHeight: 50, maxHeight: .infinity)
                        }
                        
                        HStack {
                            // Picker für die Auswahl der freien Sitze
                            // Anzahl kann nicht kleiner sein als bereits akzeptierte Fahrer
                            Picker("", selection: $viewModel.rideDetail.emptySeats) {
                                
                                let acceptedRiders = viewModel.rideDetail.riders.filter { $0.accepted }
                                
                                ForEach(acceptedRiders.count..<min(100, 256), id: \.self) { number in
                                    if number >= acceptedRiders.count && number <= 100 {
                                        Text("\(number)").tag(UInt8(number))
                                    }
                                }
                            }
                            .padding(.top, -10)
                            .foregroundColor(.gray)
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.4)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(viewModel.rideDetail.name)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar{
                // Speichern Button
                // Identische Logik wie beim anlegen neuer Fahrten
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if viewModel.isFormValid {
                            viewModel.selectedOption = "SonderFahrt"
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
