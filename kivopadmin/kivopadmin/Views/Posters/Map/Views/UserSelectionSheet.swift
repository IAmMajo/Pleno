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
                        Text(user.name) // Fallback, falls name nil ist
                        Spacer()
                        if selectedUsers.contains(user.uid) {
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
                return user.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

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


    private func dismiss() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.dismiss(animated: true, completion: nil)
        }
    }
}
