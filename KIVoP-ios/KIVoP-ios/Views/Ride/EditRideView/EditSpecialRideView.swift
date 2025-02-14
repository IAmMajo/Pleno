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
