import SwiftUI
import AuthServiceDTOs
import MeetingServiceDTOs
import PosterServiceDTOs

struct EditResponsibleUsers: View {
    @EnvironmentObject private var locationViewModel: LocationsViewModel
    @Environment(\.dismiss) var dismiss
    var poster: PosterResponseDTO
    @State var selectedUsers: [UUID]
    @State private var searchText: String = ""
    
    @ObservedObject var userManager = UserManager()
    
    var posterPosition: PosterPositionResponseDTO

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
        }
        .onDisappear {
            save()
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
            } else {
                // Benutzer auswählen
                selectedUsers.append(uid)
            }
        }
    }
    
    private func save(){
        
        // Create a new CreatePosterPositionDTO object
        let patchUserPosterPosition = CreatePosterPositionDTO(
            latitude: posterPosition.latitude,
            longitude: posterPosition.longitude,
            responsibleUsers: selectedUsers,
            expiresAt: posterPosition.expiresAt
        )
        locationViewModel.patchPosterPosition(posterPositionId: posterPosition.id, posterPosition: patchUserPosterPosition, posterId: poster.id)
        // Add the new object to the list
        //createPosterPositions.append(newPosterPosition)
        
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            locationViewModel.fetchPosterPositions(poster: poster)
        }
    }
}

