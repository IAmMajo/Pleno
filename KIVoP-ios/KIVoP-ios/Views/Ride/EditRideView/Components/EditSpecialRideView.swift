import SwiftUI

struct EditSpecialRideView: View {
    @ObservedObject var viewModel: EditRideViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            List {
                Section(header: Text("Details der Fahrt")) {
                    TextField("Name der Fahrt", text: $viewModel.ride.name)
                    ZStack(alignment: .topLeading) {
                        // Placeholder Text
                        if viewModel.ride.description == "" {
                            Text("Beschreibung oder weitere Infos zu deiner Fahrt")
                                .foregroundColor(.gray)
                                .padding(.top, 7)
                                .padding(.leading, 4)
                                .opacity(0.7)
                                .frame(height: 50)
                        }
                        
                        TextEditor(text: Binding(
                            get: { viewModel.ride.description ?? "" },
                            set: { viewModel.ride.description = $0 }
                        ))
                            .foregroundColor(.black)
                            .frame(minHeight: 50, maxHeight: .infinity)
                    }
                    .padding(.leading, -3)
                    DatePicker("Startzeit", selection: $viewModel.ride.starts, displayedComponents: [.date, .hourAndMinute])
                }
                Section(header: Text("Startort")) {
                    Text("Baut Adrian noch")
                }
                Section(header: Text("Zielort")) {
                    Text("Baut Adrian noch")
                }
                Section(header: Text("Auto und Sitzplätze")) {
                    HStack {
                        ZStack(alignment: .topLeading){
                            // Placeholder Text
                            if viewModel.ride.vehicleDescription == "" {
                                Text("Beschreibung Auto")
                                    .foregroundColor(.gray)
                                    .padding(.top, 10)
                                    .padding(.leading, 4)
                                    .opacity(0.7)
                            }
                            
                            TextEditor(text: Binding(
                                get: { viewModel.ride.vehicleDescription ?? "" },
                                set: { viewModel.ride.vehicleDescription = $0 }
                            ))
                                .foregroundColor(.black)
                                .frame(minHeight: 50, maxHeight: .infinity)
                        }
                        
                        HStack {
                            // Picker für die Auswahl der freien Sitze
                            Picker("", selection: $viewModel.ride.emptySeats) {
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
            }
            .listStyle(.insetGrouped)
            .navigationTitle(viewModel.ride.name)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar{
                // Speichern Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if viewModel.isFormValid {
                            viewModel.saveRide()
                            dismiss()
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
