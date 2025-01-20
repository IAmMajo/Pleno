import SwiftUI
import AuthServiceDTOs

struct PendingRequestsNavigationView: View {
    @Binding var isPresented: Bool
    var onListUpdate: (() -> Void)? = nil // Optionaler Callback für Updates

    @State private var requests: [UserProfileDTO] = [] // Liste der Nutzeranfragen
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
                                    email: request.email ?? "Keine E-Mail",
                                    createdAt: request.createdAt,
                                    userId: request.uid?.uuidString ?? "",
                                    profileImage: request.profileImage,
                                    onListUpdate: {
                                        fetchPendingRequests()
                                        onListUpdate?()
                                    }
                                )
                            ) {
                                HStack {
                                    profileImagePreview(for: request)
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                    
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
    
    @ViewBuilder
    private func profileImagePreview(for request: UserProfileDTO) -> some View {
        if let imageData = request.profileImage, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    Text(getInitials(from: request.name ?? "Unbekannt"))
                        .foregroundColor(.white)
                        .font(.headline)
                        .bold()
                )
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
    var email: String
    var createdAt: Date?
    var userId: String
    var profileImage: Data?
    var onListUpdate: (() -> Void)? = nil // Optionaler Callback für Updates

    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    profileImageView()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(user)
                            .font(.title3)
                            .fontWeight(.bold)
                        Text(email)
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                    Spacer()
                }
                .padding(.bottom, 20)

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
                .padding(.horizontal, 20)

                Button(action: {
                    handleUserAction(activate: false)
                }) {
                    Text("Ablehnen")
                        .frame(maxWidth: .infinity, maxHeight: 44)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
        }
        .padding()
        .navigationTitle("Beitrittsanfrage")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Profile Image Handling
    @ViewBuilder
    private func profileImageView() -> some View {
        if let imageData = profileImage, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    Text(getInitials(from: user))
                        .foregroundColor(.white)
                        .font(.title)
                        .bold()
                )
        }
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

private func getInitials(from fullName: String) -> String {
    let components = fullName.split(separator: " ")
    let firstInitial = components.first?.first?.uppercased() ?? ""
    let lastInitial = components.count > 1 ? components.last?.first?.uppercased() ?? "" : ""
    return firstInitial + lastInitial
}
