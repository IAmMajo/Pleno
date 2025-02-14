// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



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
