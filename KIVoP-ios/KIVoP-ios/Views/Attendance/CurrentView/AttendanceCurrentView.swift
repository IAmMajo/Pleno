//
//  AnwesenheitAktuellView.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 02.11.24.
//

import SwiftUI
import MeetingServiceDTOs

struct AttendanceCurrentView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: AttendanceCurrentViewModel
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                // Navbar
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.backward")
                            Text("Zurück")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    // Datum des aktuellen Termins
                    Text(viewModel.meeting.start, style: .date)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                // Suchfeld
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                    HStack {
                        TextField("Suchen", text: $viewModel.searchText)
                            .padding(8)
                    }
                    .padding(.horizontal, 8)
                }
                .frame(height: 40)
                .padding(.horizontal)
                
                // Inhalt
                ZStack {
                    Color.gray.opacity(0.1)
                        .edgesIgnoringSafeArea(.all)

                    VStack {
                        Text("Teilnahme bestätigen")
                            .padding(.top)
                            .padding(.horizontal)

                        // QR Code Button
                        Button(action: {
                            // Funktion für QR Code scannen wird später implementiert
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
                        .padding(.horizontal)

                        // "oder" Schriftzug
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
                            Spacer()
                            
                            VStack {
                                Text("\(viewModel.acceptedCount)")
                                    .font(.largeTitle)
                                Image(systemName: "person.fill.questionmark")
                                    .foregroundColor(.gray)
                                    .font(.largeTitle)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        Spacer()
                        
                        // Teilnehmerliste
                        List {
                            Section(header: Text("Mitglieder")) {
                                ForEach(viewModel.filteredAttendances, id: \.identity.id) { attendance in
                                    HStack {
                                        // Profilbild (Platzhalter)
                                        Circle()
                                            .fill(Color.gray)
                                            .frame(width: 40, height: 40)
                                        
                                        // Name
                                        VStack(alignment: .leading) {
                                            Text(attendance.identity.name)
                                                .font(.body)
                                        }
                                        
                                        Spacer()
                                        
                                        // Inline-Statusbehandlung und Anzeige von Symbolen
                                        Image(systemName:
                                            attendance.status == .present ? "checkmark" :
                                            "questionmark.circle"
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
                }
            }
        }
        .navigationBarHidden(true)
    }
}
