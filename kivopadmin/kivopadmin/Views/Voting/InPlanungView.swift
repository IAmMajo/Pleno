import SwiftUI
import MeetingServiceDTOs

struct InPlanungView: View {
    let voting: GetVotingDTO
    let onEdit: (GetVotingDTO) -> Void
    let onDelete: () -> Void
    let onOpen: () -> Void
    let onReload: () -> Void
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var lastDeleteTime: Date?
    @State private var isProcessing = false
    @State private var showEditPopup = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Frage anzeigen
                Text(voting.question)
                    .font(.title2)
                    .padding()

                // Auswahlmöglichkeiten anzeigen
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(voting.options, id: \.index) { option in
                        Text("• \(option.text)")
                            .font(.headline)
                    }
                }
                .padding()

                // Fehlermeldung anzeigen
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding()
                }

                // Buttons
                actionButton(title: "Umfrage eröffnen", icon: "play.fill", color: .green, action: openVoting)
                actionButton(title: "Umfrage bearbeiten", icon: "pencil", color: .blue) {
                    showEditPopup = true
                }
                actionButton(title: "Umfrage löschen", icon: "trash", color: .red, action: deleteVoting)
            }
        }
        .background(Color.white)
        .sheet(isPresented: $showEditPopup) {
            EditVotingView(
                voting: voting,
                onReload: {
                    onReload() // Reload-Funktion weitergeben
                },
                onSave: { updatedVoting in
                    showEditPopup = false
                    onEdit(updatedVoting) // Update-Funktion aufrufen
                    onReload() // Daten nach Bearbeitung neu laden
                }
            )
        }
    }

    // MARK: - Buttons
    private func actionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            if isProcessing {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            } else {
                Label(title, systemImage: icon)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(color)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
        .disabled(isProcessing)
    }

    // MARK: - Server API Calls
    private func openVoting() {
        guard !isProcessing else {
            print("Warnung: openVoting bereits in Bearbeitung.")
            return
        }

        isProcessing = true
        errorMessage = nil

        VotingService.shared.openVoting(votingId: voting.id) { result in
            DispatchQueue.main.async {
                self.isProcessing = false
                switch result {
                case .success:
                    print("Umfrage erfolgreich eröffnet: \(self.voting.id)")
                    onOpen() // Callback ausführen, um zur ListView zurückzukehren oder weitere Aktionen auszulösen
                case .failure(let error):
                    self.errorMessage = "Fehler beim Öffnen der Umfrage: \(error.localizedDescription)"
                    print("Fehler beim Öffnen: \(error)")
                }
            }
        }
    }



    private func deleteVoting() {
        guard !isProcessing else {
            print("Warnung: deleteVoting bereits in Bearbeitung.")
            return
        }

        isProcessing = true
        errorMessage = nil

        VotingService.shared.deleteVoting(votingId: voting.id) { result in
            DispatchQueue.main.async {
                self.isProcessing = false
                switch result {
                case .success:
                    print("Umfrage erfolgreich gelöscht: \(self.voting.id)")
                    onDelete() // Stelle sicher, dass der Callback verwendet wird
                case .failure(let error):
                    self.errorMessage = "Fehler beim Löschen der Umfrage: \(error.localizedDescription)"
                    print("Fehler beim Löschen: \(error)")
                }
            }
        }
    }



}
