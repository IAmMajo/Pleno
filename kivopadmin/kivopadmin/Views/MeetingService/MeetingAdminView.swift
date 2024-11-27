import MeetingServiceDTOs
import SwiftUI

struct MeetingAdminView: View {
    @StateObject private var meetingManager = MeetingManager() // MeetingManager als StateObject

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
                    List(meetingManager.meetings, id: \.id) { meeting in
                        NavigationLink(destination: MeetingDetailAdminView(meeting: meeting)) {
                            VStack(alignment: .leading) {
                                Text(meeting.name)
                                    .font(.headline)
                                Text("Start: \(meeting.start.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }

                // Button, um ein neues Meeting zu erstellen
                NavigationLink(destination: CreateMeetingView()) {
                    Text("Create Meeting")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.top, 20)
                }
            }
            .padding()
            .navigationTitle("Meeting Administration")
            .onAppear {
                meetingManager.fetchAllMeetings() // Meetings laden, wenn die View erscheint
            }
        }
    }
}

#Preview {
    MeetingAdminView()
}
