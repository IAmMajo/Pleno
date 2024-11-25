//
//  AnwesenheitPlanungView.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 02.11.24.
//

import SwiftUI

struct AttendancePlanningView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText: String = ""
    var event: Event
    
    // Beispiel-Mitgliederliste
    @State private var members: [Member] = [
        Member(name: "Max Mustermann", title: "Sitzungsleiter", hasVoted: .yes),
        Member(name: "Erika Mustermann", title: "Stellvertretende", hasVoted: .no),
        Member(name: "Hans Müller"),
        Member(name: "Maria Meier", hasVoted: .yes),
        Member(name: "Lukas Schmidt", hasVoted: .no)
    ]
    
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

    // Beispiel: Aktueller Nutzer, dessen Teilnahme erfasst wird
    @State private var currentUser: Member = Member(name: "Aktueller Nutzer", title: nil, hasVoted: nil)
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 16) {
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
                    Text(event.date, style: .date)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
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
                        Button(action: {
                            // Aktion für Sprachsuche (optional)
                        }) {
                            Image(systemName: "mic.fill")
                                .foregroundColor(.gray)
                        }
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
                    // Titel für Teilnahme-Umfrage
                    Text("Kannst du an diesem Termin?")
                        .font(.title2)
                        .padding(.top, 20)
                    
                    // Teilnahme Schaltflächen
                    HStack(spacing: 40) {
                        // "Ja"-Button
                        Button(action: {
                            currentUser.hasVoted = .yes
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
                            currentUser.hasVoted = .no
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
                    .padding(.top, 20)
                    
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
                    
                    // Teilnehmerliste
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
