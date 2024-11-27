import SwiftUI
import AuthServiceDTOs
import MeetingServiceDTOs
import UIKit

struct MainPage: View {
    @State private var name: String = ""
    @State private var shortName: String = "??"
    @State private var profileImage: UIImage? = nil
    @State private var meeting: String? = nil
    @State private var meetingDate: String? = nil
    @State private var meetingTime: String? = nil
    @State private var attendeesCount: Int? = nil
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                // Begrüßung
                if isLoading {
                    ProgressView("Laden...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Text("Hallo, \(extractFirstName(from: name))")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primary)
                        .padding([.top, .leading], 20)
                }

                // Profil-Informationen
                NavigationLink(destination: MainPage_ProfilView()) {
                    HStack {
                        if let profileImage = profileImage {
                            // Profilbild anzeigen, wenn vorhanden
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        } else {
                            // Shortname-Kreis als Fallback
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 50, height: 50)
                                .overlay(Text(shortName).foregroundColor(.white))
                        }

                        VStack(alignment: .leading) {
                            Text(name.isEmpty ? "Name laden..." : name)
                                .font(.headline)
                                .foregroundColor(Color.primary)
                            Text("Profil und Vereinsinformationen")
                                .font(.subheadline)
                                .foregroundColor(Color.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(Color.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground).opacity(0.8))
                    .cornerRadius(15)
                    .padding(.horizontal, 10)
                    .padding(10)
                }

                // Options List
                List {
                    Section {
                        NavigationLink(destination: Meeting()) {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                    .foregroundColor(.accentColor)
                                Text("Sitzungen")
                                    .foregroundColor(Color.primary)
                            }
                        }
                    }

                    Section {
                        NavigationLink(destination: VotingsView()) {
                            HStack {
                                Image(systemName: "chart.pie.fill")
                                    .foregroundColor(.accentColor)
                                Text("Abstimmungen")
                                    .foregroundColor(Color.primary)
                            }
                        }

                        NavigationLink(destination: ProtokolleView()) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundColor(.accentColor)
                                Text("Protokolle")
                                    .foregroundColor(Color.primary)
                            }
                        }

                        NavigationLink(destination: AnwesenheitView()) {
                            HStack {
                                Image(systemName: "person.crop.circle.fill.badge.checkmark")
                                    .foregroundColor(.accentColor)
                                Text("Anwesenheit")
                                    .foregroundColor(Color.primary)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .background(Color.clear)
                .padding(.top, -10)

                Spacer()

                // Meeting Box
                if let meeting = meeting {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(meeting)
                            .font(.headline)
                            .foregroundColor(.white)

                        HStack {
                            if let meetingDate = meetingDate {
                                Image(systemName: "calendar")
                                    .foregroundColor(.white)
                                Text(meetingDate)
                                    .foregroundColor(.white)
                            }

                            Spacer()

                            if let attendeesCount = attendeesCount {
                                HStack(spacing: 4) {
                                    Text("\(attendeesCount)")
                                        .foregroundColor(.white)
                                    Image(systemName: "person.3")
                                        .foregroundColor(.white)
                                }
                                .padding(.trailing, 10)
                            }
                        }

                        if let meetingTime = meetingTime {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.white)
                                Text(meetingTime)
                                    .foregroundColor(.white)

                                Spacer()
                            }
                        }

                        Button(action: {
                            // Aktion für das aktuelle Meeting
                        }) {
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
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .navigationBarHidden(true)
        .onAppear {
            loadUserProfile()
            loadCurrentMeeting()
        }
    }

    // MARK: - Daten laden
    private func loadUserProfile() {
        MainPageAPI.fetchUserProfile { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let profile):
                    self.name = profile.name ?? ""
                    self.shortName = MainPageAPI.calculateShortName(from: profile.name ?? "")
                    self.loadProfilePicture() // Profilbild laden
                case .failure(let error):
                    self.errorMessage = "Fehler beim Laden des Profils: \(error.localizedDescription)"
                }
            }
        }
    }

    private func loadProfilePicture() {
        MainPageAPI.fetchProfilePicture { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let image):
                    self.profileImage = image
                case .failure:
                    self.profileImage = nil // Kein Bild verfügbar
                }
            }
        }
    }

    private func loadCurrentMeeting() {
        MainPageAPI.fetchCurrentMeeting { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let meeting):
                    if let meeting = meeting {
                        self.meeting = meeting.name
                        self.meetingDate = formatDate(meeting.start)
                        self.meetingTime = formatTime(meeting.start)
                        self.attendeesCount = meeting.duration.map { Int($0) }
                    }
                case .failure(let error):
                    print("Fehler beim Laden des Meetings: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Helferfunktionen
    private func extractFirstName(from fullName: String) -> String {
        return fullName.split(separator: " ").first.map(String.init) ?? "Nutzer"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct MainPage_Previews: PreviewProvider {
    static var previews: some View {
        MainPage()
    }
}



// Sample Views für die anderen Punkte nach hinzufügen bitte löschen!!!

struct ProtokolleView: View {
    var body: some View {
        Text("Protokolle")
            .font(.largeTitle)
    }
}
