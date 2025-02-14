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

//
//  AttendancePlanningView.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 02.11.24.
//

import SwiftUI

struct AttendancePlanningView: View {
    @ObservedObject var viewModel: AttendancePlanningViewModel
    
    var body: some View {
        NavigationStack {
            // Den gesamten Hintergrund grau hinterlegen
            ZStack {
                Color.gray.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                // Inhalt
                VStack {
                    // Titel für Teilnahme-Umfrage
                    Text("Kannst du an diesem Termin?")
                        .font(.title2)
                        .padding(.top, 20)
                    
                    // Teilnahme Schaltflächen
                    HStack(spacing: 40) {
                        Button(action: {
                            viewModel.markAttendanceAsAccepted()
                        }) {
                            HStack {
                                Image(systemName: "checkmark")
                                Text("Ja")
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        // "Nein"-Button
                        Button(action: {
                            viewModel.markAttendanceAsAbsent()
                        }) {
                            HStack {
                                Image(systemName: "xmark")
                                Text("Nein")
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                        }
                    }
                    
                    // Fußzeile mit Hinweis
                    Text("Dies ist nur eine vorläufige Umfrage, um festzustellen, wie viele Mitglieder kommen.")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                    
                    // Teilnahme Status Icons
                    HStack {
                        Spacer()
                        VStack {
                            Text("\(viewModel.acceptedCount)")
                                .font(.largeTitle)
                            Image(systemName: "person.fill.checkmark")
                                .foregroundColor(.blue)
                                .font(.largeTitle)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("\(viewModel.nilCount)")
                                .font(.largeTitle)
                            Image(systemName: "person.fill.questionmark")
                                .foregroundColor(.gray)
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
                                    Text(attendance.identity.name)
                                        .font(.body)
                                        .fontWeight(attendance.itsame ? .bold : .regular)
                                    
                                    Spacer()
                                    
                                    // Symbole zum anzeigen des Anwesenheitsstatus
                                    Image(systemName:
                                        attendance.status == .absent ? "xmark.circle" :
                                        attendance.status == .accepted ? "checkmark.circle" :
                                        "questionmark.circle"
                                    )
                                    .foregroundColor(
                                        attendance.status == .absent ? .red :
                                        attendance.status == .accepted ? .blue :
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
