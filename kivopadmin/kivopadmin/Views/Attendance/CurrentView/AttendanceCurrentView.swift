//
//  AttendanceCurrentView.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 02.11.24.
//

import SwiftUI

struct AttendanceCurrentView: View {
    @State private var isShowingScanner = false
    @StateObject var viewModel: AttendanceCurrentViewModel
    
    var body: some View {
        NavigationStack {
            // Den gesamten Hintergrund grau hinterlegen
            ZStack {
                Color.gray.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                
                // Inhalt
                VStack {
                    Text("Teilnahme bestätigen")
                        .padding(.top)
                        .padding(.horizontal)

                    // QR Code Button
                    Button(action: {
                        isShowingScanner = true
                    }) {
                        HStack {
                            Image(systemName: "qrcode")
                            Text("Code scannen")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }

                    Text("oder")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                        .padding(.horizontal)

                    // Textfeld für Teilnahmecode
                    TextField("Teilnahmecode", text: $viewModel.participationCode)
                        .multilineTextAlignment(.center)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 0).fill(Color.white))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 2))
                        .frame(width: 200)
                        .onSubmit {
                            viewModel.joinMeeting() // Meeting beitreten
                        }

                    // Antwort ob Beitritt zum Meeting erfolgreich ist.
                    if let message = viewModel.statusMessage {
                        Text(message)
                            .foregroundColor(message == "Erfolgreich der Sitzung beigetreten." ? .green : .red)
                            .padding()
                    }

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
                            Text("\(viewModel.acceptedCount)")
                                .font(.largeTitle)
                            Image(systemName: "person.fill.questionmark")
                                .foregroundColor(.orange)
                                .font(.largeTitle)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    Spacer()
                    
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
                                        "checkmark.circle.badge.questionmark"
                                    )
                                    .foregroundColor(
                                        attendance.status == .present ? .blue :
                                                .gray
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
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
        }
    }
}
