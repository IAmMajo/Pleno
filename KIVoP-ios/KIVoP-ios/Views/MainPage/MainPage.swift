import SwiftUI
import AuthServiceDTOs
import MeetingServiceDTOs

struct MainPage: View {
    @State private var name: String = ""
    @State private var shortName: String = "MM"
    @State private var meeting: String? = nil
    @State private var meetingDate: String? = nil
    @State private var meetingTime: String? = nil
    @State private var attendeesCount: Int? = nil
    @State private var isLoading = true
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                // Greeting
                if isLoading {
                    ProgressView()
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

                // Profile Information
                NavigationLink(destination: MainPage_ProfilView()) {
                    HStack {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 50, height: 50)
                            .overlay(Text(shortName).foregroundColor(.white))

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
                            // Action for the current meeting
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
            fetchUserProfile()
            fetchCurrentMeeting()
        }
    }

    // MARK: - API Logic

    private func fetchUserProfile() {
        guard let url = URL(string: "https://kivop.ipv64.net/users/profile") else {
            self.errorMessage = "Ungültige URL."
            self.isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "jwtToken") ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Fehler: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                      let data = data else {
                    self.errorMessage = "Profil konnte nicht geladen werden."
                    return
                }

                do {
                    let profile = try JSONDecoder().decode(UserProfileDTO.self, from: data)
                    self.name = profile.name ?? ""
                    self.shortName = calculateShortName(from: profile.name ?? "")
                } catch {
                    self.errorMessage = "Fehler beim Verarbeiten der Daten."
                }
            }
        }.resume()
    }

    private func fetchCurrentMeeting() {
        guard let url = URL(string: "https://kivop.ipv64.net/meetings") else {
            self.errorMessage = "Ungültige URL."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "jwtToken") ?? "")", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Fehler beim Laden des Meetings: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                      let data = data else {
                    return
                }

                do {
                    let meetings = try JSONDecoder().decode([GetMeetingDTO].self, from: data)
                    if let currentMeeting = meetings.first {
                        self.meeting = currentMeeting.name
                        self.meetingDate = formatDate(currentMeeting.start)
                        self.meetingTime = formatTime(currentMeeting.start)
                        self.attendeesCount = currentMeeting.duration.map { Int($0) }
                    }
                } catch {
                    print("Fehler beim Verarbeiten der Meeting-Daten: \(error.localizedDescription)")
                }
            }
        }.resume()
    }

    // MARK: - Helpers

    private func calculateShortName(from fullName: String) -> String {
        let nameParts = fullName.split(separator: " ")
        guard let firstInitial = nameParts.first?.prefix(1),
              let lastInitial = nameParts.last?.prefix(1) else {
            return "??"
        }
        return "\(firstInitial)\(lastInitial)".uppercased()
    }

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



// Sample Views für die anderen Punkte nach hinzufügen bitte löschen!!!

struct ProtokolleView: View {
    var body: some View {
        Text("Protokolle")
            .font(.largeTitle)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainPage()
    }
}
