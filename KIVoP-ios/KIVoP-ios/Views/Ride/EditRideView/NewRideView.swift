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

// Diese View beinhaltet entweder den Inhalt um eine neue SonderFahrt anzulegen oder um eine neue EventFahrt anzulegen
// Dazu wird wenn die View erscheint der SelectionAlert geöffnet, und der Nutzer wählt zwischen den beiden Optionen
// Anhand dessen wird die jeweilige View geöffnet
struct NewRideView: View {
    @ObservedObject var viewModel: EditRideViewModel
    @ObservedObject var rideViewModel: RideViewModel
    @State var showingSaveAlert = false
    @State var selectingSaveAlert: ActiveAlert = .error
    @State var showingBackAlert = false
    @State var showingSelectionAlert = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                if let selectedOption = viewModel.selectedOption {
                    if selectedOption == "EventFahrt" {
                        CreateEventRideView(viewModel: viewModel, selectedOption: $viewModel.selectedOption)
                    } else if selectedOption == "SonderFahrt" {
                        CreateSpecialRideView(viewModel: viewModel, selectedOption: $viewModel.selectedOption)
                    }
                }
            }
            .navigationBarTitle("Neue Fahrt", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                showingSelectionAlert = true
            }
            .overlay {
                if viewModel.isLoading {
                  ProgressView("Lädt...")
               }
            }
            .toolbar {
                // Speichern Button
                // Wenn EventFahrt wird erst geprüft, ob der Nutzer am Event teilnimmt. Wenn nicht kommt die Meldung, dass er erst teilnehmen muss bevor er speichern kann
                // Sonst wird geprüft ob alle Felder ausgefüllt sind
                // Wenn ja -> speichern -> schließen -> Reiter "Meine Fahrten", wenn nein -> Fehlermeldung, Nutzer kann die Fahrt bearbeiten
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if viewModel.selectedOption == "EventFahrt",
                            let event = viewModel.events.first(where: { $0.id == viewModel.selectedEventId }), event.myState != .present {
                            selectingSaveAlert = .participate
                        } else if viewModel.isFormValid {
                            selectingSaveAlert = .save
                        } else {
                            selectingSaveAlert = .error
                        }
                        showingSaveAlert.toggle()
                    }) {
                        Text("Speichern")
                            .font(.body)
                    }
                    .alert(isPresented: $showingSaveAlert) {
                        switch selectingSaveAlert {
                        case .save:
                            Alert(
                                title: Text("Möchtest du wirklich speichern?"),
                                message: Text("Deine Fahrt wird dann veröffentlicht und andere können dieser beitreten."),
                                primaryButton: .default(Text("Ja"), action: {
                                    viewModel.saveRide()
                                    rideViewModel.selectedTab = 2
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        dismiss()
                                    }
                                }),
                                secondaryButton: .cancel()
                            )
                        case .error:
                            Alert(
                                title: Text("Fehler"),
                                message: Text("Bitte füllen Sie alle Felder aus. Das Startdatum muss außerdem in der Zukunft liegen."),
                                dismissButton: .default(Text("OK"))
                            )
                        case .participate:
                            Alert(
                                title: Text("Fehler"),
                                message: Text("Sie müssen erst am Event teilnehmen, bevor Sie an der Fahrgemeinschaft teilnehmen"),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                    }
                }
                // Zurück Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingBackAlert.toggle()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Zurück")
                                .font(.body)
                        }
                    }
                    .alert(isPresented: $showingBackAlert) {
                        Alert(
                            title: Text("Möchtest du wirklich zurück?"),
                            message: Text("Deine gesamten Änderungen gehen verloren!"),
                            primaryButton: .default(Text("Nein")),
                            secondaryButton: .destructive(Text("Ja").foregroundColor(.red), action: {
                                dismiss()
                            })
                        )
                    }
                }
            }
            .alert(isPresented: $showingSelectionAlert) {
                Alert(
                    title: Text("Wähle die Art der Fahrt"),
                    message: Text("Bitte wähle, ob du eine Event Fahrt oder eine Sonderfahrt anlegen möchtest."),
                    primaryButton: .default(Text("Event Fahrt"), action: {
                        viewModel.selectedOption = "EventFahrt"
                    }),
                    secondaryButton: .default(Text("Sonderfahrt"), action: {
                        viewModel.selectedOption = "SonderFahrt"
                    })
                )
            }
        }
    }
}
