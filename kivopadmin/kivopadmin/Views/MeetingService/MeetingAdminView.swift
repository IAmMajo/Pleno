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



import MeetingServiceDTOs
import SwiftUI

struct MeetingAdminView: View {
    // ViewModel als EnvironmentObject
    @EnvironmentObject private var meetingManager : MeetingManager
    
    // Standardmäßig werden beim Picker die bevorstehenden Sitzungen angezeigt
    @State private var selectedStatus: FilterType = .scheduled
    
    // Text der Suchleiste
    @State private var searchText: String = ""
    
    // Bool Variable für Create-Sheet
    @State private var showCreateMeeting = false
    
    // Filter Typen für den Picker
    enum FilterType: String, CaseIterable {
        case scheduled = "In Planung"
        case inSession = "Aktiv"
        case completed = "Abgeschlossen"
    }

    // Je nach Auswahl des Pickers werden die Sitzungen angezeigt
    var filteredMeetings: [GetMeetingDTO] {
        meetingManager.meetings
            .filter { meeting in
                switch selectedStatus {
                case .scheduled:
                    return meeting.status == .scheduled
                case .inSession:
                    return meeting.status == .inSession
                case .completed:
                    return meeting.status == .completed
                }
            }
            .filter { meeting in
                searchText.isEmpty || meeting.name.localizedCaseInsensitiveContains(searchText)
            }
    }





    var body: some View {
        NavigationStack {
            VStack {
                if meetingManager.isLoading {
                    ProgressView("Lade Sitzungen...") // Ladeanzeige
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let errorMessage = meetingManager.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else if meetingManager.meetings.isEmpty {
                    Text("Keine Sitzungen verfügbar")
                        .foregroundColor(.secondary)
                } else {
                    // Picker für Auswahl des Sitzungs-Status
                    Picker("Filter", selection: $selectedStatus) {
                        ForEach(FilterType.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Searchbar
                    searchBar
                    
                    // Liste der Meetings
                    listView
                }
            }
            .navigationTitle("Sitzungen") // Navigation Title
            .onAppear {
                meetingManager.fetchAllMeetings() // Meetings laden, wenn die View erscheint
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreateMeeting = true }) {
                        Label("Erstellen", systemImage: "plus")
                    }
                }
            }
            .refreshable {
                meetingManager.fetchAllMeetings()
            }
            .sheet(isPresented: $showCreateMeeting) {
                CreateMeetingView().environmentObject(meetingManager)
            }
        }
    }
}

extension MeetingAdminView {
    private var searchBar: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Nach Sitzung suchen", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .padding(.horizontal)
    }
    
    private var listView: some View {
        List {
            // Schleife über alle Sitzungen
            ForEach(filteredMeetings, id: \.id) { meeting in
                // Navigation zur Detailansicht 
                NavigationLink(destination: MeetingDetailAdminView(meeting: meeting)) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(meeting.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("Sitzung am \(DateTimeFormatter.formatDate(meeting.start)) um \(DateTimeFormatter.formatTime(meeting.start))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .listRowBackground(Color(.systemBackground))
            }
        }
        .listStyle(PlainListStyle())
    }
}
