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

import SwiftUI
import MeetingServiceDTOs

struct MeetingView: View {
    @State private var selectedSegment = "Anstehend" // Auswahl für den Picker
    @State private var searchText = "" // Suchtext
    
    // Array mit Sitzungen wird übergeben
    var meetings: [GetMeetingDTO] // Array von Meetings als Eingabe
    
    
    // Gefilterte Meetings basierend auf Suchtext
    var filteredMeetings: [GetMeetingDTO] {
        guard !searchText.isEmpty else { return meetings }
        return meetings.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    // Aktuelle Sitzungen werden nach Status gefiltert
    var currentMeetings: [GetMeetingDTO] {
        filteredMeetings.filter { $0.status == .inSession }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Aktuelle Sitzungen werden oben angezeigt und sind immer sichtbar
                List {
                    // Aktuelle Sitzungen
                    currentMeetingsView(currentMeetings: currentMeetings)
                    
                    // Sektion mit dem Picker
                    Picker("Auswahl", selection: $selectedSegment) {
                        Text("Anstehend").tag("Anstehend")
                        Text("Vergangen").tag("Vergangen")
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear) // Hintergrund der Zeile entfernen
                    .padding(-20)
                    
                    // Meetings je nach Auswahl anzeigen
                    if selectedSegment == "Anstehend" {
                        UpcomingMeetingsView(meetings: filteredMeetings.filter { $0.status == .scheduled })
                    } else {
                        PastMeetingsView(meetings: filteredMeetings.filter { $0.status == .completed })
                    }

                }
                .searchable(text: $searchText)
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Sitzungen")
        }
        
    }
    
    private func currentMeetingsView(currentMeetings: [GetMeetingDTO]) -> some View {
        Group{
            if !currentMeetings.isEmpty {
                Section(header: Text("Aktuelle Sitzungen")) {
                    ForEach(currentMeetings, id: \.id) { meeting in
                        NavigationLink(destination: MeetingDetailView(meeting: meeting)) {
                            HStack {
                                Image(systemName: "play.circle")
                                    .foregroundColor(.red)
                                VStack(alignment: .leading) {
                                    Text(meeting.name)
                                        .foregroundStyle(.red)
                                    Text(meeting.start, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// Unteransicht für anstehende Sitzungen
struct UpcomingMeetingsView: View {
    var meetings: [GetMeetingDTO]
    
    var body: some View {
        
        Section(header: Text("Anstehende Sitzungen")) {
            if meetings.isEmpty {
                Text("Keine anstehenden Sitzungen.")
                    .foregroundColor(.gray)
                    .italic()
            } else {
                ForEach(meetings, id: \.id) { meeting in
                    // Link zur Detailansicht
                    NavigationLink(destination: MeetingDetailView(meeting: meeting)) {
                        VStack(alignment: .leading) {
                            Text(meeting.name)
                            Text(meeting.start, style: .date) // Zeigt das Datum im richtigen Format an
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// Unteransicht für vergangene Sitzungen
struct PastMeetingsView: View {
    var meetings: [GetMeetingDTO]
    
    var body: some View {
        
        Section(header: Text("Vergangene Sitzungen")) {
            if meetings.isEmpty {
                Text("Keine vergangenen Sitzungen.")
                    .foregroundColor(.gray)
                    .italic()
            } else {
                ForEach(meetings, id: \.id) { meeting in
                    // Link zur Detailansicht
                    NavigationLink(destination: MeetingDetailView(meeting: meeting)) {
                        VStack(alignment: .leading) {
                            Text(meeting.name)
                            Text(meeting.start, style: .date) // Zeigt das Datum im passenden Format
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

