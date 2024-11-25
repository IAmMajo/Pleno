//
//  AnwesenheitView.swift
//  KIVoP-ios
//
//  Created by Henrik Peltzer on 02.11.24.
//

import SwiftUI

struct AttendanceView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText: String = ""
    @State private var selectedTab: Tab = .past
    
    // dateFormatter Funktion damit das Datum im richtigen Format angezeigt wird.
    private let dateFormatter: DateFormatter

    init() {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "dd.MM.yyyy"
    }
    
    // Der attendance value ist zurzeit nur zur Visualisierung. Der Status wird vom jeweiligen Mitglied übernommen, je nachdem ob das angemeldete Mitglied an dem Termin teilgenommen hatte oder nicht.
    // Der scheduled Wert wird der Basis Wert sein.
    @State private var events: [Event] = [
        Event(title: "Jahreshauptversammlung", date: Date(), status: "current"),
        Event(title: "Treffen 1", date: Calendar.current.date(byAdding: .day, value: -10, to: Date())!, attendance: .attended, status: "past"),
        Event(title: "Treffen 2", date: Calendar.current.date(byAdding: .day, value: -20, to: Date())!, attendance: .missed, status: "past"),
        Event(title: "Treffen 3", date: Calendar.current.date(byAdding: .month, value: -1, to: Date())!, attendance: .attended, status: "past"),
        Event(title: "Planungs-Meeting", date: Calendar.current.date(byAdding: .day, value: 10, to: Date())!, status: "scheduled"),
        Event(title: "Feedback-Runde", date: Calendar.current.date(byAdding: .day, value: 20, to: Date())!, status: "scheduled")
    ]
    
    // Aus dem Event Array wird das aktuelle Event gezogen.
    // Das sowie das Event Array ist nur vorrübergehend hier, bis echte Testdaten verwendet werden
    var currentEvents: [Event] {
        events.filter { $0.status == "current" }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Navbar
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Zurück")
                    }
                    .foregroundColor(.blue)
                }
                .padding(.horizontal)

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
                
                // Inhalt
                ZStack {
                    Color.gray.opacity(0.1)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Aktuelle Sitzung, falls es keine gibt, wird angezeigt das es keine aktuelle Sitzung gibt
                        VStack(alignment: .leading, spacing: 4) {
                            Text("AKTUELLE SITZUNG")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                                .padding(.leading)
                            
                            if !currentEvents.isEmpty {
                                ForEach(currentEvents) { event in
                                    NavigationLink(destination: destinationView(for: event)) {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(event.title)
                                                    .foregroundColor(.white)
                                                Text(dateFormatter.string(from: event.date))
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                            }
                                            .padding(.vertical, 4)
                                            Spacer()
                                            Image(systemName: "clock")
                                                .foregroundColor(.yellow)
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.white)
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 2)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                    }
                                }
                            } else {
                                // Platzhalter-Text, wenn es keine aktuelle Sitzung gibt
                                Text("Aktuell ist keine Sitzung im Gange.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray.opacity(0.7))
                                    .padding(.leading)
                            }
                        }
                        .padding(.horizontal)
                        
                        // TabView für vergangene und vorgeschlagene Termine
                        Picker("Termine", selection: $selectedTab) {
                            Text("Vergangene Termine").tag(Tab.past)
                            Text("Anstehende Termine").tag(Tab.scheduled)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        // Liste der Termine
                        List {
                            // Aufsplittung nach Monaten.
                            ForEach(getEvents(for: selectedTab)) { month in
                                Section(header: Text(month.name)) {
                                    ForEach(month.events) { event in
                                        NavigationLink(destination: destinationView(for: event)) {
                                            HStack {
                                                VStack(alignment: .leading) {
                                                    Text(event.title)
                                                    Text(dateFormatter.string(from: event.date))
                                                        .font(.footnote)
                                                }
                                                .padding(.vertical, -2)
                                                Spacer()
                                                if selectedTab == .past {
                                                    Image(systemName: event.attendance == .attended ? "checkmark" : "xmark")
                                                        .foregroundColor(event.attendance == .attended ? .blue : .red)
                                                } else if selectedTab == .scheduled {
                                                    // Wenn abgestimmt wurde Haken oder X.
                                                    // Wenn noch nicht abgestimmt wurde anderes Icon.
                                                    Image(systemName: event.attendance == .attended ? "checkmark" : (event.attendance == .missed ? "xmark" : "calendar"))
                                                        .foregroundColor(event.attendance == .attended ? .blue : (event.attendance == .missed ? .red : .orange))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top, -10)
                        .listStyle(InsetGroupedListStyle())
                    }
                    .padding(.top)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    func destinationView(for event: Event) -> some View {
        if event.status == "past" {
            return AnyView(AttendanceDetailView(event: event))
        } else if event.status == "scheduled" {
            return AnyView(AttendancePlanningView(event: event))
        } else {
            return AnyView(AttendanceCurrentView(event: event))
        }
    }
    
    // Funktion, um Events nach Monaten zu gruppieren
    private func getEvents(for tab: Tab) -> [MonthGroup] {
        // Filtern der Events basierend auf der ausgewählten Registerkarte. Aktuelle Events werden nicht angezeigt.
        let filteredEvents = events.filter { event in
            guard event.status != "current" else {
                return false
            }
            
            if tab == .past {
                return event.status == "past"
            } else {
                return event.status == "scheduled"
            }
        }
        // Gruppierung der gefilterten Events nach Monat und Jahr
        let groupedEvents = Dictionary(grouping: filteredEvents) { event in
            Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: event.date))!
        }
        // Erstellen von MonthGroup für jede Gruppierung, formatiert nach Monat und Jahr
        return groupedEvents.map { (key, value) in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM - yyyy"
            let monthName = formatter.string(from: key)
            return MonthGroup(name: monthName, events: value)
        }.sorted(by: { $0.name < $1.name }) // Sortierung nach Monat
    }
}

// Modelle und Enums zur Strukturierung der Daten
struct MonthGroup: Identifiable {
    let id = UUID()
    let name: String
    let events: [Event]
}

struct Event: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    var attendance: AttendanceStatus?
    var status: String
}

enum AttendanceStatus {
    case attended, missed
}

enum Tab {
    case past, scheduled
}

// Vorschau für SwiftUI
struct AttendanceView_Previews: PreviewProvider {
    static var previews: some View {
        AttendanceView()
    }
}
