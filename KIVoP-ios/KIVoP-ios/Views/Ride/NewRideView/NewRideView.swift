//
//  NewRideView.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 06.01.25.
//

import SwiftUI

struct NewRideView: View {
    @ObservedObject var viewModel: NewRideViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingSaveAlert = false
    @State private var showingBackAlert = false

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section(header: Text("Details der Fahrt")){
                        
                    }
                    Section(header: Text("Startort")){
                        
                    }
                    Section(header: Text("Zielort")){
                        
                    }
                    Section(header: Text("Auto und Sitzplätze")){
                        
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Neue Fahrt")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
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
                             primaryButton:.default(Text("Nein")),
                            secondaryButton:.destructive(Text("Ja").foregroundColor(.red), action: {
                                 dismiss()
                             })
                        )
                    }
                }
            }
        }
    }
}

