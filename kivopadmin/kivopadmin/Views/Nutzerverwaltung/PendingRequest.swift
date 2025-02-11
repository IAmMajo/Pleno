// This file is licensed under the MIT-0 License.

import SwiftUI
import AuthServiceDTOs

struct PendingRequestsNavigationView: View {
    @Binding var isPresented: Bool // Steuert, ob die Ansicht angezeigt wird
    @StateObject private var viewModel: PendingRequestsViewModel

    // Initialisiert die View mit einem optionalen Callback zur Aktualisierung der Liste
    init(isPresented: Binding<Bool>, onListUpdate: (() -> Void)? = nil) {
        self._isPresented = isPresented
        self._viewModel = StateObject(wrappedValue: PendingRequestsViewModel(onListUpdate: onListUpdate))
    }

    var body: some View {
        NavigationStack {
            VStack {
                // Ladeindikator während die Anfragen geladen werden
                if viewModel.isLoading {
                    ProgressView("Lade Anfragen...")
                        .padding()
                
                // Fehlermeldung, falls das Laden fehlschlägt
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                
                // Anzeige der Anfragen in einer Liste
                } else {
                    List {
                        ForEach(viewModel.requests, id: \.uid.uuidString) { request in
                            NavigationLink(
                                destination: PendingRequestPopup(
                                    viewModel: viewModel,
                                    user: request
                                )
                            ) {
                                HStack {
                                    profileImagePreview(for: request)
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading) {
                                        Text(request.name)
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
                // Zurück-Button zur Schließung der Ansicht
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Zurück") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    // Zeigt entweder das Profilbild oder ein Platzhalterbild mit Initialen an
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
                    Text(getInitials(from: request.name))
                        .foregroundColor(.white)
                        .font(.headline)
                        .bold()
                )
        }
    }
}

// Helferklasse für die Datumsformatierung
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

// Extrahiert die Initialen aus dem Namen
private func getInitials(from fullName: String) -> String {
    let components = fullName.split(separator: " ")
    let firstInitial = components.first?.first?.uppercased() ?? ""
    let lastInitial = components.count > 1 ? components.last?.first?.uppercased() ?? "" : ""
    return firstInitial + lastInitial
}
