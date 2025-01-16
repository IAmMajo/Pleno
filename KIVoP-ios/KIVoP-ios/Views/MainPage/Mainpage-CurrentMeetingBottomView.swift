import SwiftUI
import MeetingServiceDTOs

struct CurrentMeetingBottomView: View {
    @StateObject private var meetingManager = MeetingManager()
    @State private var activeMeetingID: UUID? // UUID statt GetMeetingDTO, um Hashable zu sein
    
    @StateObject private var attendanceManager = AttendanceManager() // RecordManager als StateObject
    
    var body: some View {
        Group {
            if let currentMeeting = meetingManager.currentMeeting {
                VStack {
                    if meetingManager.meetings.filter { $0.status == .inSession }.count > 1 {
                        ScrollView(.horizontal) {
                            HStack {
                                filteredMeetingsView
                            }
                            .scrollTargetLayout()
                        }
                        .scrollTargetBehavior(.viewAligned)
                        .scrollPosition(id: $activeMeetingID) // Verwende nur die ID für die Scroll-Position
                        .scrollIndicators(.never)
                        pagingControl
                    } else {
                        // Zeige das einzelne Meeting ohne ScrollView an
                        filteredMeetingsView
                    }
                }
                .onAppear {
                    // Setze die erste Sitzung mit Status 'inSession' als aktive Sitzung
                    activeMeetingID = meetingManager.meetings.filter { $0.status == .inSession }.first?.id
                }
            } else {
                Text("Keine Sitzung verfügbar")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .italic()
                    .padding()
            }
        }
        .onAppear {
            meetingManager.fetchAllMeetings()
        }
    }
    
    private var filteredMeetingsView: some View {
        ForEach(meetingManager.meetings.filter { $0.status == .inSession }, id: \.id) { meeting in
            meetingView(for: meeting)
        }
        .containerRelativeFrame(.horizontal, count: 1, spacing: 0)

    }

    private func meetingView(for meeting: GetMeetingDTO) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(meeting.name)
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.white)
                Text(DateTimeFormatter.formatDate(meeting.start)) // Beispiel: Datum
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 4) { // kleiner Abstand zwischen dem Symbol und der Personenanzahl
                    if attendanceManager.isLoading {
                        Text("Loading...")
                    } else if let errorMessage = attendanceManager.errorMessage {
                        Text("Error: \(errorMessage)")
                    } else {
                        Text("\(attendanceManager.numberOfParticipants())")
                            .foregroundStyle(.white)
                    }
                    Image(systemName: "person.3.fill").foregroundStyle(.white) // Symbol für eine Gruppe von Personen
                }
            }
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.white)
                Text(DateTimeFormatter.formatTime(meeting.start)) // Beispiel: Uhrzeit
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            NavigationLink(destination: MeetingDetailView(meeting: meeting)) {
                Text("Zur aktuellen Sitzung")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.systemBackground))
                    .foregroundColor(.accentColor)
                    .cornerRadius(10)
            }

        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(15)
        .padding(.horizontal, 12)
        .padding(.bottom, 20)
        .onAppear(){
            attendanceManager.fetchAttendances(meetingId: meeting.id)
        }
    }

    private var pagingControl: some View {
        HStack {
            ForEach(meetingManager.meetings.filter { $0.status == .inSession }, id: \.id) { meeting in
                Button {
                    withAnimation {
                        activeMeetingID = meeting.id // Setze die ID des aktiven Meetings
                    }
                } label: {
                    Image(systemName: activeMeetingID == meeting.id ? "circle.fill" : "circle")
                        .foregroundStyle(Color(uiColor: .systemGray3))
                }
            }
        }
    }
}
