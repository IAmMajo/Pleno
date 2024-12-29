import MeetingServiceDTOs
import SwiftUI

struct MeetingAdminView: View {
    @StateObject private var meetingManager = MeetingManager() // MeetingManager als StateObject
    
    @State private var selectedStatus: FilterType = .scheduled
    @State private var searchText: String = ""
    @State private var showCreateMeeting = false
    
    enum FilterType: String, CaseIterable {
        case scheduled = "In Planung"
        case inSession = "Aktiv"
        case completed = "Abgeschlossen"
    }

    
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
                    ProgressView("Loading meetings...") // Ladeanzeige
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let errorMessage = meetingManager.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else if meetingManager.meetings.isEmpty {
                    Text("No meetings available.")
                        .foregroundColor(.secondary)
                } else {
                    // Picker
                    Picker("Filter", selection: $selectedStatus) {
                        ForEach(FilterType.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Searchbar
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Nach Frage suchen", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    // Liste der Meetings
                    List {
                        ForEach(filteredMeetings, id: \.id) { meeting in
                            NavigationLink(destination: MeetingDetailAdminView(meeting: meeting)) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(meeting.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("Start: \(meeting.start.formatted(date: .abbreviated, time: .shortened))")
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
            .sheet(isPresented: $showCreateMeeting) {
                CreateMeetingView()
            }
        }
    }


}

#Preview {
    MeetingAdminView()
}
