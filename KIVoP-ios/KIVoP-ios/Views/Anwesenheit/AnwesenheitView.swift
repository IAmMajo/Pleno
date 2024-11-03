//
//  AnwesenheitView.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 02.11.24.
//

import SwiftUI

// Datenmodelle werden ausgelagert, sobald Daten übers backend verfügbar sind.

struct AnwesenheitView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText: String = ""
    @State private var selectedTab: Tab = .past
    @State private var showAnwesenheitAktuellView = false
    
    @State private var currentMeeting = Meeting(title: "Jahreshauptversammlung", date: Date())
    @State private var pastMeetings: [Meeting] = [
        Meeting(title: "Termin-Titel", date: Calendar.current.date(byAdding: .day, value: -10, to: Date())!, attendance: .attended),
        Meeting(title: "Termin-Titel", date: Calendar.current.date(byAdding: .day, value: -20, to: Date())!, attendance: .missed),
        Meeting(title: "Termin-Titel", date: Calendar.current.date(byAdding: .month, value: -1, to: Date())!, attendance: .attended)
    ]
    @State private var proposedMeetings: [Meeting] = [
        Meeting(title: "Planungs-Meeting", date: Calendar.current.date(byAdding: .day, value: 10, to: Date())!),
        Meeting(title: "Feedback-Runde", date: Calendar.current.date(byAdding: .day, value: 20, to: Date())!)
    ]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Zurück-Button
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Zurück")
                    }
                    .foregroundColor(.blue)
                    .padding(.leading)
                }
                
                // Titel
                Text("Anwesenheit")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                
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
                
                // Grauer Hintergrund für den unteren Inhalt
                ZStack {
                    Color.gray.opacity(0.1)
                        .edgesIgnoringSafeArea(.all)

                    VStack(alignment: .leading, spacing: 16) {
                        // Aktuelle Sitzung
                        VStack(alignment: .leading, spacing: 4) {
                            Text("AKTUELLE SITZUNG")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                                .padding(.leading)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(currentMeeting.title)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text(currentMeeting.date, style: .date)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                Spacer()
                                Image(systemName: "clock")
                                    .foregroundColor(.yellow)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .onTapGesture {
                                showAnwesenheitAktuellView.toggle()
                            }
                        }
                        .padding(.horizontal)
                        
                        // TabView für vergangene und vorgeschlagene Termine
                        Picker("Termine", selection: $selectedTab) {
                            Text("Vergangene Termine").tag(Tab.past)
                            Text("Vorgeschlagene Termine").tag(Tab.proposed)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        // Liste der Termine
                        List {
                            // Aufsplittung nach Monaten. Schema soll "Monat - Jahr" sein.
                            ForEach(getMeetings(for: selectedTab)) { month in
                                Section(header: Text(month.name)) {
                                    ForEach(month.meetings) { meeting in
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(meeting.title)
                                                    .font(.body)
                                                Text(meeting.date, style: .date)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                            if selectedTab == .past {
                                                Image(systemName: meeting.attendance == .attended ? "checkmark" : "xmark")
                                                    .foregroundColor(meeting.attendance == .attended ? .blue : .red)
                                            }
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.vertical, 8)
                                    }
                                }
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                    .padding(.top)
                }
                .fullScreenCover(isPresented: $showAnwesenheitAktuellView) {
                    AnwesenheitAktuellView(meeting: currentMeeting)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // Funktion, um Meetings nach Monaten zu gruppieren
    private func getMeetings(for tab: Tab) -> [MonthGroup] {
        let meetings = tab == .past ? pastMeetings : proposedMeetings
        
        // Gruppierung der Meetings nach Monat
        let groupedMeetings = Dictionary(grouping: meetings) { meeting in
            Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: meeting.date))!
        }
        
        // Erstellen von MonthGroup für jede Gruppierung mit nur Monat und Jahr
        return groupedMeetings.map { (key, value) in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            let monthName = formatter.string(from: key)
            return MonthGroup(name: monthName, meetings: value)
        }.sorted(by: { $0.name < $1.name }) // Sortierung nach Monat
    }
}

// Strukturen zur Gruppierung der Meetings
struct MonthGroup: Identifiable {
    let id = UUID()
    let name: String
    let meetings: [Meeting]
}

// Modelle und Enums zur Strukturierung der Daten
struct Meeting: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    var attendance: AttendanceStatus?
}

enum AttendanceStatus {
    case attended, missed
}

enum Tab {
    case past, proposed
}

// Vorschau für SwiftUI
struct AnwesenheitView_Previews: PreviewProvider {
    static var previews: some View {
        AnwesenheitView()
    }
}
