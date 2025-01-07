//
//  NewRideView.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 06.01.25.
//

import SwiftUI

struct NewRideView: View {
    @ObservedObject var viewModel: NewRideViewModel
    @State var showingSaveAlert = false
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
            .navigationTitle("Neue Fahrt")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                showingSelectionAlert = true
            }
            .toolbar {
                // Speichern Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSaveAlert.toggle()
                    }) {
                        Text("Speichern")
                            .font(.body)
                    }
                    .alert(isPresented: $showingSaveAlert) {
                        Alert(
                            title: Text("Möchtest du wirklich speichern?"),
                            message: Text("Deine Fahrt wird dann veröffentlicht und andere können dieser beitreten."),
                            primaryButton: .default(Text("Ja"), action: {
                                viewModel.saveRide()
                                dismiss()
                            }),
                            secondaryButton: .cancel()
                        )
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
