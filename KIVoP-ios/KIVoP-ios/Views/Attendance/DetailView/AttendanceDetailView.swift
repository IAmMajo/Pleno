//
//  AttendanceDetailView.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 02.11.24.
//

import SwiftUI

struct AttendanceDetailView: View {
    @ObservedObject var viewModel: AttendanceDetailViewModel
    
    var body: some View {
        NavigationStack {
            // Den gesamten Hintergrund grau hinterlegen
            ZStack {
                Color.gray.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                // Inhalt
                VStack {
                    // Teilnahme Status Icons
                    HStack {
                        Spacer()
                        VStack {
                            Text("\(viewModel.presentCount)")
                                .font(.largeTitle)
                            Image(systemName: "person.fill.checkmark")
                                .foregroundColor(.blue)
                                .font(.largeTitle)
                        }
                        Spacer()
                        VStack {
                            Text("\(viewModel.absentCount)")
                                .font(.largeTitle)
                            Image(systemName: "person.fill.xmark")
                                .foregroundColor(.orange)
                                .font(.largeTitle)
                        }
                        Spacer()
                    }
                    .padding(.top)
                    
                    // Teilnehmerliste
                    List {
                        Section(header: Text("Mitglieder")) {
                            ForEach(viewModel.attendances, id: \.identity.id) { attendance in
                                HStack {
                                    // Profilbild (Platzhalter)
                                    Circle()
                                        .fill(Color.gray)
                                        .frame(width: 40, height: 40)
                                    
                                    // Name (der eigene Name wird fett gedruckt)
                                    VStack(alignment: .leading) {
                                        Text(attendance.identity.name)
                                            .font(.body)
                                            .fontWeight(attendance.itsame ? .bold : .regular)
                                    }
                                    
                                    Spacer()
                                    
                                    // Inline-Statusbehandlung und Anzeige von Symbolen
                                    Image(systemName:
                                        attendance.status == .present ? "checkmark.circle" :
                                        "xmark.circle"
                                    )
                                    .foregroundColor(
                                        attendance.status == .present ? .blue :
                                        .red
                                    )
                                    .font(.system(size: 18))
                                }
                            }
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
                       viewModel.fetchAttendances()
                   }
                }
                .refreshable {
                    Task {
                        viewModel.fetchAttendances()
                    }
                }
            }
            .navigationTitle(Text(viewModel.meeting.start, style: .date))
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
        }
    }
}

