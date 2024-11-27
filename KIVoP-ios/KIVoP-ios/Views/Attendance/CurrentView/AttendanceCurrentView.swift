//
//  AnwesenheitAktuellView.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 02.11.24.
//

import SwiftUI
import MeetingServiceDTOs

struct AttendanceCurrentView: View {
    var meeting: GetMeetingDTO
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText: String = ""
    @State private var participationCode: String = ""
    
    // Beispiel-Mitgliederliste
    @State private var members: [Member] = []
    
    // Sortierung der Mitglieder, falls noch nicht abgestimt wurde wird nach .yes sortiert.
    var sortedMembers: [Member] {
        members.sorted {
            if $0.hasVoted == $1.hasVoted {
                return $0.name < $1.name
            }
            if $0.hasVoted == .yes {
                return true
            }
            if $1.hasVoted == .yes {
                return false
            }
            if $0.hasVoted == nil {
                return true
            }
            if $1.hasVoted == nil {
                return false
            }
            return false
        }
    }
    
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
                    Text(meeting.start, style: .date)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    Spacer()
                    Spacer()
                }
                .padding(.horizontal)
                
                // Suchfeld
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                    HStack {
                        TextField("Suchen", text: $searchText)
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
                        TextField("Teilnahmecode", text: $participationCode)
                            .multilineTextAlignment(.center)
                            .padding(8)
                            .background(RoundedRectangle(cornerRadius: 0).fill(Color.white))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 2))
                            .frame(width: 200)
                        
                        // Teilnahme Status Icons
                        HStack {
                            Spacer()
                            VStack {
                                Text("\(members.filter { $0.hasVoted == .yes }.count)")
                                    .font(.largeTitle)
                                Image(systemName: "person.fill.checkmark")
                                    .foregroundColor(.blue)
                                    .font(.largeTitle)
                            }
                            
                            Spacer()
                            Spacer()
                            
                            VStack {
                                Text("\(members.filter { $0.hasVoted == nil }.count)")
                                    .font(.largeTitle)
                                Image(systemName: "person.fill.questionmark")
                                    .foregroundColor(.gray)
                                    .font(.largeTitle)
                            }
                            
                            Spacer()
                            Spacer()
                            
                            VStack {
                                Text("\(members.filter { $0.hasVoted == .no }.count)")
                                    .font(.largeTitle)
                                Image(systemName: "person.fill.xmark")
                                    .foregroundColor(.orange)
                                    .font(.largeTitle)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        Spacer()
                        
                        // Mitgliederliste
                        List {
                            Section(header: Text("Mitglieder")) {
                                ForEach(sortedMembers) { member in
                                    HStack {
                                        // Profilbild (Platzhalter)
                                        Circle()
                                            .fill(Color.gray)
                                            .frame(width: 40, height: 40)
                                        
                                        // Name und Titel
                                        VStack(alignment: .leading) {
                                            Text(member.name)
                                                .font(.body)
                                            if let title = member.title {
                                                Text(title)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        Spacer()
                                        
                                        // Abstimmungssymbol
                                        Image(systemName: member.hasVoted?.icon ?? VoteStatus.notVoted.icon)
                                            .foregroundColor(member.hasVoted?.color ?? VoteStatus.notVoted.color)
                                            .font(.system(size: 22))
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

struct Member: Identifiable {
    let id = UUID()
    let name: String
    var title: String?
    var hasVoted: VoteStatus?
}

enum VoteStatus {
    case yes
    case no
    case notVoted
    
    var icon: String {
        switch self {
        case .yes:
            return "checkmark"
        case .notVoted:
            return "questionmark.circle"
        case .no:
            return "xmark"
        }
    }
    
    var color: Color {
        switch self {
        case .yes:
            return .blue
        case .notVoted:
            return .gray
        case .no:
            return .red
        }
    }
}
