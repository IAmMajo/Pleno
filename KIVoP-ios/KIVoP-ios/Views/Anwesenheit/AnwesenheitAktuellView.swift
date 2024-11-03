//
//  AnwesenheitAktuellView.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 02.11.24.
//

import SwiftUI

// Datenmodelle und Testdaten werden ausgelagert und entfernt, sobald das backend implemntiert ist

// Brauchen wir den Namen des Termins?

// Sortierung der Mitgleider steht noch aus

struct AnwesenheitAktuellView: View {
    var meeting: Meeting
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText: String = ""
    @State private var participationCode: String = ""
    
    // Beispielwerte für die Anzahl der Teilnehmer
    @State private var participantsCount: [String: Int] = [
        "teilgenommen": 5,
        "ausstehend": 2,
        "nicht_teilgenommen": 1
    ]
    
    // Beispiel-Mitgliederliste
    @State private var members: [Member] = [
        Member(name: "Max Mustermann", title: "Sitzungsleiter", hasVoted: .yes),
        Member(name: "Erika Mustermann", title: "Stellvertretende", hasVoted: .pending),
        Member(name: "Hans Müller", hasVoted: .no)
    ]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                // Navbar
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
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
                
                // Grauer Hintergrund
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
                                Text("\(participantsCount["teilgenommen"] ?? 0)")
                                    .font(.largeTitle)
                                Image(systemName: "person.fill.checkmark")
                                    .foregroundColor(.blue)
                                    .font(.largeTitle)
                            }
                            
                            Spacer()
                            Spacer()
                            
                            VStack {
                                Text("\(participantsCount["ausstehend"] ?? 0)")
                                    .font(.largeTitle)
                                Image(systemName: "person.fill.questionmark")
                                    .foregroundColor(.gray)
                                    .font(.largeTitle)
                            }
                            
                            Spacer()
                            Spacer()
                            
                            VStack {
                                Text("\(participantsCount["nicht_teilgenommen"] ?? 0)")
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
                            Section(header: Text("Mitglieder")
                                        .font(.headline)
                                        .foregroundColor(.gray)) {
                                ForEach(members) { member in
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
                                        Image(systemName: member.hasVoted.icon)
                                            .foregroundColor(member.hasVoted.color)
                                            .font(.system(size: 22))
                                    }
                                    .padding(.vertical, 8) // Padding für jedes Listenelement
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}


// Datenmodell für Mitglieder
struct Member: Identifiable {
    let id = UUID()
    let name: String
    var title: String?
    var hasVoted: VoteStatus
}

// Abstimmungstatus
enum VoteStatus {
    case yes
    case pending
    case no
    
    var icon: String {
        switch self {
        case .yes:
            return "checkmark"
        case .pending:
            return "questionmark.circle"
        case .no:
            return "xmark"
        }
    }
    
    var color: Color {
        switch self {
        case .yes:
            return .blue
        case .pending:
            return .gray
        case .no:
            return .red
        }
    }
}

// Vorschau für AnwesenheitAktuellView
struct AnwesenheitAktuellView_Previews: PreviewProvider {
    static var previews: some View {
        AnwesenheitAktuellView(
            meeting: Meeting(
                title: "Jahreshauptversammlung",
                date: Date()
            )
        )
    }
}
