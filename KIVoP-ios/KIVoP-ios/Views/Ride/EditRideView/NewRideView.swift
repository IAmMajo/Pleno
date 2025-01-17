import SwiftUI

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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if viewModel.isFormValid {
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
                                    dismiss()
                                }),
                                secondaryButton: .cancel()
                            )
                        case .error:
                            Alert(
                                title: Text("Fehler"),
                                message: Text("Bitte füllen Sie alle Felder aus. Das Startdatum muss außerdem in der Zukunft liegen."),
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
