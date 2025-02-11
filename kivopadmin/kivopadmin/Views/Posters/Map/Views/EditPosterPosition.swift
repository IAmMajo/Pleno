import SwiftUI
import AuthServiceDTOs
import MeetingServiceDTOs
import PosterServiceDTOs

struct EditPosterPosition: View {
    @EnvironmentObject private var locationViewModel: LocationsViewModel
    @Environment(\.dismiss) var dismiss
    var poster: PosterResponseDTO
    @State var selectedUsers: [UUID]
    @State private var searchText: String = ""
    
    @ObservedObject var userManager = UserManager()
    
    var posterPosition: PosterPositionResponseDTO
    @Binding var date: Date
    var body: some View {
        NavigationStack {
            HStack{
                Text("Ablaufdatum")
                    .font(.headline)
                Spacer()
                DatePicker("", selection: $date)
                    .datePickerStyle(CompactDatePickerStyle())
            }.padding()
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
            date = posterPosition.expiresAt
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
                return user.name.localizedCaseInsensitiveContains(searchText)
                return false
            }
        }
    }

    private func toggleSelection(for user: UserProfileDTO) {
        let uid = user.uid
        if let index = selectedUsers.firstIndex(of: uid) {
            // Benutzer abwählen
            selectedUsers.remove(at: index)
        } else {
            // Benutzer auswählen
            selectedUsers.append(uid)
        }
    }
    
    private func save(){
        
        // Create a new CreatePosterPositionDTO object
        let patchUserPosterPosition = CreatePosterPositionDTO(
            latitude: posterPosition.latitude,
            longitude: posterPosition.longitude,
            responsibleUsers: selectedUsers,
            expiresAt: date
        )
        locationViewModel.patchPosterPosition(posterPositionId: posterPosition.id, posterPosition: patchUserPosterPosition, posterId: poster.id)
        
        // Eine Sekunde warten, damit der Server die Daten empfangen und speichern kann
        // Dann kann erneut ein GET Aufruf getätigt werden, wo die aktualisierten Daten mitgeliefert werden
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            locationViewModel.fetchPosterPositions(poster: poster)
        }
    }
}

