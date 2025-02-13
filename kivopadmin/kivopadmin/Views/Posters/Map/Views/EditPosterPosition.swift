// This file is licensed under the MIT-0 License.

import SwiftUI
import AuthServiceDTOs
import MeetingServiceDTOs
import PosterServiceDTOs

struct EditPosterPosition: View {
    
    // locationViewModel als EnvironmentObject
    @EnvironmentObject private var locationViewModel: LocationsViewModel
    
    @Environment(\.dismiss) var dismiss
    
    // es wird der Sammelposten, von dem eine Plakatposition bearbeitet werden soll, beim Aufruf der View mitgeliefert
    var poster: PosterResponseDTO
    
    // Plakatposition wird beim Aufruf der View mitgeliefert
    var posterPosition: PosterPositionResponseDTO
    
    // alle Verantwortlichen Personen werden mitgeliefert
    @State var selectedUsers: [UUID]
    
    // Searchstring für Suchleiste
    @State private var searchText: String = ""
    
    // ViewModel für die Benutzerverwaltung
    @ObservedObject var userManager = UserManager()

    // Ablaufdatum
    @Binding var date: Date
    
    var body: some View {
        NavigationStack {
            HStack{
                Text("Ablaufdatum")
                    .font(.headline)
                Spacer()
                // Picker zum auswählen des Ablaufdatums
                DatePicker("", selection: $date)
                    .datePickerStyle(CompactDatePickerStyle())
            }.padding()
            List {
                // Alle verfügbaren User werden aufgelistet
                ForEach(filteredUsers, id: \.email) { user in
                    HStack {
                        Text(user.name) // Fallback, falls name nil ist
                        Spacer()
                        // Verantwortliche Personen
                        // Wenn im Array selectedUsers die Id vorhanden ist, wird der User mit einem blauen Haken markiert
                        if selectedUsers.contains(user.uid) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Auswahl togglen
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
            // beim Aufruf der View wird die Variable date mit dem tatsächlichen Verfallsdatum befüllt
            date = posterPosition.expiresAt
            
            // alle User laden
            userManager.fetchActiveUsers()
        }
        .onDisappear {
            // wenn die View verlassen wird, wird gespeichert
            save()
        }
    }

    // gefilterte Benutzer auf Basis des Searchstrings
    private var filteredUsers: [UserProfileDTO] {
        if searchText.isEmpty {
            return userManager.users
        } else {
            return userManager.users.filter { user in
                return user.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // Auswahl der Person togglen
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
    
    // Funktion zum speichern der Plakatposition
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

