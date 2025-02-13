// This file is licensed under the MIT-0 License.

import SwiftUI
import AuthServiceDTOs
import MeetingServiceDTOs

struct UserSelectionSheet: View {
    // locationViewModel als EnvironmentObject
    @EnvironmentObject private var locationViewModel: LocationsViewModel
    
    @Environment(\.dismiss) private var dismiss
    // alle Benutzer werden dieser View übergeben
    var users: [UserProfileDTO]
    
    // Array mit allen IDs der ausgewählten Nutzer
    @Binding var selectedUsers: [UUID]
    
    // Suchtext
    @State private var searchText: String = ""
    
    // viewModel für die Nutzerverwaltung
    @ObservedObject var userManager = UserManager()
    
    // lokale Kopie der ausgewählten User Names (wird beim Aufrufen dieser View befüllt)
    @State private var localSelectedUserNames: [String] = []

    var body: some View {
        NavigationStack {
            List {
                // Schleife über alle User unter Berücksichtigung der Suche
                ForEach(filteredUsers, id: \.email) { user in
                    HStack {
                        Text(user.name) // Fallback, falls name nil ist
                        Spacer()
                        // Wenn ein User ausgewählt wurde, erscheint dort ein blauer Haken
                        if selectedUsers.contains(user.uid) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // bei Klick auf einen User wird die Auswahl getogglet
                        toggleSelection(for: user)
                    }
                }
            }
            .navigationTitle("Benutzer auswählen")
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    // Sheet schließen
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            // User laden bei ViewAufruf
            userManager.fetchActiveUsers()
            
            // lokale Kopie der ausgewählten UserNames
            localSelectedUserNames = locationViewModel.selectedUserNames
        }
        .onDisappear {
            // Wenn das Sheet geschlossen wird, wird die Variable des Viewmodels überschrieben
            locationViewModel.selectedUserNames = localSelectedUserNames
        }
    }

    // gefilterte User unter Berücksichtigung der Suche
    private var filteredUsers: [UserProfileDTO] {
        if searchText.isEmpty {
            return userManager.users
        } else {
            return userManager.users.filter { user in
                return user.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    // Auswahl des Benutzers togglen
    private func toggleSelection(for user: UserProfileDTO) {
        let uid = user.uid
        if let index = selectedUsers.firstIndex(of: uid) {
            // Benutzer abwählen
            selectedUsers.remove(at: index)

            if let nameIndex = localSelectedUserNames.firstIndex(of: user.name) {
                localSelectedUserNames.remove(at: nameIndex)
            }
            
            
        } else {
            // Benutzer auswählen
            selectedUsers.append(uid)

            localSelectedUserNames.append(user.name)
        }
    }
}
