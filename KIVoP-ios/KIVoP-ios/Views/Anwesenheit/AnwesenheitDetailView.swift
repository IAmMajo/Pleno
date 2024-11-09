//
//  AnwesenheitDetailView.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 02.11.24.
//

import SwiftUI

struct AnwesenheitDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText: String = ""
    var meeting: Meeting
    
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
                    Text(meeting.date, style: .date)
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
                        
                        Spacer()
                        Spacer()
                        
                        // Teilnahme Status Icons (nur für die abgestimmten Mitglieder)
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
                                Text("\(members.filter { $0.hasVoted == .no || $0.hasVoted == nil }.count)")
                                    .font(.largeTitle)
                                Image(systemName: "person.fill.xmark")
                                    .foregroundColor(.orange)
                                    .font(.largeTitle)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        Spacer()
                        
                        // Mitgliederliste
                        List {
                            Section(header: Text("Mitglieder")) {
                                ForEach(sortedMembers) { member in
                                    let voteStatus = member.hasVoted ?? .no
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
                                        
                                        Image(systemName: voteStatus.icon)
                                            .foregroundColor(voteStatus.color)
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

struct AnwesenheitDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AnwesenheitDetailView(
            meeting: Meeting(
                title: "Jahreshauptversammlung",
                date: Date(),
                status: "past"
            )
        )
    }
}
