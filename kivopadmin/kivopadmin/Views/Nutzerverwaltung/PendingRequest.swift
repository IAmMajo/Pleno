import SwiftUI
import AuthServiceDTOs

struct PendingRequestsNavigationView: View {
    @Binding var isPresented: Bool
    @State private var requests: [UserEmailVerificationDTO] = [] // Liste der Nutzeranfragen
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Lade Anfragen...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    List {
                        ForEach(requests, id: \.uid?.uuidString) { request in
                            NavigationLink(
                                destination: PendingRequestPopup(
                                    user: request.name ?? "Unbekannt",
                                    createdAt: request.createdAt,
                                    userId: request.uid?.uuidString ?? ""
                                )
                            ) {
                                VStack(alignment: .leading) {
                                    Text(request.name ?? "Unbekannt")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color.primary)
                                    Text("Erstellt am: \(DateFormatterHelper.formattedDate(from: request.createdAt))")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.secondary)
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Beitrittsanfragen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Zurück") {
                        isPresented = false
                    }
                }
            }
            .onAppear {
                fetchPendingRequests()
            }
        }
    }

    private func fetchPendingRequests() {
        isLoading = true
        errorMessage = nil
        print("Starte Anfrage für ausstehende Nutzer...")

        MainPageAPI.fetchPendingUsers { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let users):
                    print("API Response: \(users)")
                    self.requests = users.filter { $0.isActive == false }
                case .failure(let error):
                    print("Fehler beim Abrufen der Anfragen: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct PendingRequestPopup: View {
    var user: String
    var createdAt: Date?
    var userId: String // Benutzer-ID für Aktionen

    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(user)
                        .foregroundColor(Color.secondary)
                }
                HStack {
                    Text("Erstellt am")
                    Spacer()
                    Text(DateFormatterHelper.formattedDate(from: createdAt))
                        .foregroundColor(Color.secondary)
                }
                Divider()
            }
            .padding()

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Spacer()

            // Buttons am unteren Rand
            VStack(spacing: 10) {
                Button(action: {
                    handleUserAction(activate: true)
                }) {
                    Text("Bestätigen")
                        .frame(maxWidth: .infinity, maxHeight: 44)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: {
                    handleUserAction(activate: false)
                }) {
                    Text("Ablehnen")
                        .frame(maxWidth: .infinity, maxHeight: 44)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .padding()
        .navigationTitle("Beitrittsanfrage: \(user)")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func handleUserAction(activate: Bool) {
        isLoading = true
        errorMessage = nil

        if activate {
            print("Benutzer wird aktiviert: \(userId)")
            MainPageAPI.activateUser(userId: userId) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success():
                        print("Benutzer erfolgreich aktiviert: \(userId)")
                        // 1 Sekunde warten, dann zurück zur Liste
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    case .failure(let error):
                        print("Fehler beim Aktivieren des Benutzers: \(error.localizedDescription)")
                        errorMessage = error.localizedDescription
                    }
                }
            }
        } else {
            print("Benutzer wird abgelehnt: \(userId)")
            MainPageAPI.deleteUser(userId: userId) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success():
                        print("Benutzer erfolgreich gelöscht: \(userId)")
                        // 1 Sekunde warten, dann zurück zur Liste
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    case .failure(let error):
                        print("Fehler beim Ablehnen des Benutzers: \(error.localizedDescription)")
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}

struct DateFormatterHelper {
    static func formattedDate(from date: Date?) -> String {
        guard let date = date else { return "Unbekanntes Datum" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
