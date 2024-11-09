import SwiftUI

struct Meeting: View {
    @State private var selectedSegment = "Anstehend" // Auswahl für den Picker
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                // Erste Sektion für die "Aktuelle Sitzung", immer sichtbar
                List {
                    Section(header: Text("Aktuelle Sitzung")) {
                        NavigationLink(destination: CurrentMeeting()) {
                            HStack {
                                Image(systemName: "play.circle")
                                    .foregroundColor(.red)
                                Text("Jahreshauptversammlung").foregroundStyle(.red)
                            }
                        }
                    }
                    // Sektion mit dem Picker
                    Picker("Auswahl", selection: $selectedSegment) {
                        Text("Anstehend").tag("Anstehend")
                        Text("Vergangen").tag("Vergangen")
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear) // Hintergrund der Zeile entfernen
                    .padding(-20)
                    
                    // Inhalt basierend auf dem ausgewählten Segment
                    if selectedSegment == "Anstehend" {
                        UpcomingMeetingsView()
                    } else {
                        PastMeetingsView()
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Sitzungen")
        }
        .searchable(text: $searchText)
    }
}

// Unteransicht für anstehende Sitzungen
struct UpcomingMeetingsView: View {
    var body: some View {
        Section(header: Text("Dezember 2023")) {
            NavigationLink(destination: MeetingDetail()) {
                VStack(alignment: .leading){
                    Text("Vorstandsitzung Dez. 23")
                    Text("01.12.23")
                        .font(.caption) // Kleiner Schriftgrad
                        .foregroundColor(.gray) // Graue Farbe
                }
            }
            NavigationLink(destination: MeetingDetail()) {
                VStack(alignment: .leading){
                    Text("Treffen mit Förderverein")
                    Text("01.12.23")
                        .font(.caption) // Kleiner Schriftgrad
                        .foregroundColor(.gray) // Graue Farbe
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// Unteransicht für vergangene Sitzungen
struct PastMeetingsView: View {
    var body: some View {
        Section(header: Text("November 2023")) {
            NavigationLink(destination: MeetingDetail()) {
                VStack(alignment: .leading){
                    Text("Vorstandsitzung Nov. 23")
                    Text("01.11.23")
                        .font(.caption) // Kleiner Schriftgrad
                        .foregroundColor(.gray) // Graue Farbe
                }
            }
            NavigationLink(destination: MeetingDetail()) {
                VStack(alignment: .leading){
                    Text("Treffen mit Kassenwart")
                    Text("04.11.23")
                        .font(.caption) // Kleiner Schriftgrad
                        .foregroundColor(.gray) // Graue Farbe
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

#Preview {
    Meeting()
}
