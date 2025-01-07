//
//  RideView.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 04.01.25.
//

import SwiftUI

struct RideView: View {
    @StateObject private var viewModel = RideViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingNewRideAlert = false
    @State private var navigateToNewRide = false
    
    var body: some View {
        NavigationStack {
            // Inhalt
            VStack {
                // Fahrgemeinschaften
                List {
                    // TabView Event Fahrten, Sonstige, meine Fahrten
                    Picker("", selection: $viewModel.selectedTab) {
                        Text("Events").tag(0)
                        Text("Sonstige Fahrten").tag(1)
                        Text("Meine Fahrten").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    
                    // Liste für die jeweiligen Fahrten
                    Section{
                        ForEach(viewModel.rides, id: \.id) { ride in
                            //NavigationLink(viewModel.destinationView(for: ride)) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(ride.name)
                                            .font(.headline)
                                        Text(DateTimeFormatter.formatDate(ride.starts))
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    
                                    Image(systemName: "car.fill")
                                        // Symbol Grau, da noch keine Teilnehmer-Logik verfügbar
                                        .foregroundColor(.gray)
                                        .font(.system(size: 18))
                                }
                            //}
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .overlay {
                    if viewModel.isLoading {
                      ProgressView("Lädt...")
                   }
                }
                .onAppear {
                   Task {
                       //viewModel.fetchMeetings()
                   }
                }
                .refreshable {
                    Task {
                        //viewModel.fetchMeetings()
                    }
                }
            }
            .navigationTitle("Fahrgemeinschaften")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                // Neue Fahrt anbieten
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: NewRideView(viewModel: NewRideViewModel())) {
                        Text("Neue Fahrt anbieten")
                            .font(.body)
                    }
                }
                
                // Zurück Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Zurück")
                                .font(.body)
                        }
                    }
                }
            }
        }
    }
}
