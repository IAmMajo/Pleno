//
//  CreateSpecialRideView.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 07.01.25.
//

import SwiftUI

struct CreateSpecialRideView: View {
    @ObservedObject var viewModel: NewRideViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedOption: String?

    var body: some View {
        VStack {
            List {
                Section(header: Text("Details der Fahrt")) {
                    TextField("Name der Fahrt", text: $viewModel.rideName)
                    ZStack(alignment: .topLeading) {
                        // Placeholder Text
                        if viewModel.rideDescription.isEmpty {
                            Text("Beschreibung der Fahrt")
                                .foregroundColor(.gray)
                                .padding(.top, -11)
                                .padding(.leading, 4)
                                .opacity(0.7)
                                .frame(height: 50)
                        }
                        
                        TextEditor(text: $viewModel.rideDescription)
                            .foregroundColor(.black)
                            .frame(minHeight: 50, maxHeight: .infinity)
                    }
                    .padding(.leading, -3)
                    DatePicker("Startzeit", selection: $viewModel.starts, displayedComponents: [.date, .hourAndMinute])
                }
                Section(header: Text("Startort")) {

                }
                Section(header: Text("Zielort")) {
                    Text("Zielort eingeben")
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
                                ForEach(1..<100) { number in
                                    Text("\(number)").tag(number as Int?)
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
            .navigationTitle("Neue Fahrt")
        }
    }
}
