// This file is licensed under the MIT-0 License.

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
        switch selectedStatus {
        case .scheduled:
            return meetingManager.meetings.filter { $0.status == .scheduled }
        case .inSession:
            return meetingManager.meetings.filter { $0.status == .inSession }
        case .completed:
            return meetingManager.meetings.filter { $0.status == .completed }
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
