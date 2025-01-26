import SwiftUI
import AuthServiceDTOs
import MeetingServiceDTOs

struct UserSelectionSheet: View {
    @EnvironmentObject private var locationViewModel: LocationsViewModel
    
    var users: [UserProfileDTO]
    @Binding var selectedUsers: [UUID]
    @State private var searchText: String = ""
    
    @ObservedObject var userManager = UserManager()
    
    @State private var localSelectedUserNames: [String] = []

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredUsers, id: \.email) { user in
                    HStack {
                        Text(user.name ?? "Unbekannter Name") // Fallback, falls name nil ist
                        Spacer()
                        if let uid = user.uid, selectedUsers.contains(uid) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        toggleSelection(for: user)
                    }
                }
            }
            .navigationTitle("Benutzer auswählen")
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        print(userManager.users)
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            userManager.fetchUsers()
            localSelectedUserNames = locationViewModel.selectedUserNames
        }
        .onDisappear {
            locationViewModel.selectedUserNames = localSelectedUserNames
        }
    }

    private var filteredUsers: [UserProfileDTO] {
        if searchText.isEmpty {
            return userManager.users
        } else {
            return userManager.users.filter { user in
                if let name = user.name {
                    return name.localizedCaseInsensitiveContains(searchText)
                }
                return false
            }
        }
    }

    private func toggleSelection(for user: UserProfileDTO) {
        if let uid = user.uid {
            if let index = selectedUsers.firstIndex(of: uid) {
                // Benutzer abwählen
                selectedUsers.remove(at: index)
                if let name = user.name, let nameIndex = localSelectedUserNames.firstIndex(of: name) {
                    localSelectedUserNames.remove(at: nameIndex)
                }
            } else {
                // Benutzer auswählen
                selectedUsers.append(uid)
                if let name = user.name {
                    localSelectedUserNames.append(name)
                }
            }
        }
    }

    private func dismiss() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.dismiss(animated: true, completion: nil)
        }
    }
}
