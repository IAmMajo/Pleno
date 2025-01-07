//
//  CreateEventRideView.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 07.01.25.
//

import SwiftUI

struct CreateEventRideView: View {
    @ObservedObject var viewModel: NewRideViewModel
    @Binding var selectedOption: String?

    var body: some View {
        VStack {
            List {
                Section(header: Text("Details der Fahrt")) {
                    Text("Event-spezifische Details")
                }
                Section(header: Text("Startort")) {
                    Text("Startort für die Event Fahrt")
                }
                Section(header: Text("Zielort")) {
                    Text("Zielort für die Event Fahrt")
                }
                Section(header: Text("Auto und Sitzplätze")) {
                    Text("Fahrzeug und Sitzplatzdetails")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Event Fahrt")
        }
    }
}
