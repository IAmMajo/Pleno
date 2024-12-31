import SwiftUI
import AuthServiceDTOs

struct PendingRequestsNavigationView: View {
    @Binding var isPresented: Bool
    var onListUpdate: (() -> Void)? = nil // Optionaler Callback für Updates

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
                                    userId: request.uid?.uuidString ?? "",
                                    onListUpdate: {
                                        fetchPendingRequests() // Liste aktualisieren
                                        onListUpdate?() // Callback zur Haupt-View
                                    }
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

        MainPageAPI.fetchPendingUsers { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let users):
                    self.requests = users.filter { $0.isActive == false }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct PendingRequestPopup: View {
    var user: String
    var createdAt: Date?
    var userId: String
    var onListUpdate: (() -> Void)? = nil // Optionaler Callback für Updates

    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
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

            Spacer()
        }
        .padding()
        .navigationTitle("Beitrittsanfrage: \(user)")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func handleUserAction(activate: Bool) {
        isLoading = true
        errorMessage = nil

        let action = activate ? "aktiviert" : "abgelehnt"
        print("Benutzer wird \(action): \(userId)")

        let apiCall: (_ userId: String, @escaping (Result<Void, Error>) -> Void) -> Void = activate
            ? MainPageAPI.activateUser
            : MainPageAPI.deleteUser

        apiCall(userId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    print("Benutzer erfolgreich \(action): \(userId)")
                    onListUpdate?()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                case .failure(let error):
                    print("Fehler beim \(action) des Benutzers: \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct DateFormatterHelper {
    static func formattedDate(from date: Date?) -> String {
        guard let date = date else { return "Unbekanntes Datum" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE") // Deutsche Formatierung
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
