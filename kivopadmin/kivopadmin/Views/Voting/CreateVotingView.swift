import SwiftUI
import MeetingServiceDTOs

struct CreateVotingView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var question = ""
    @State private var description = ""
    @State private var anonymous = false
    @State private var options: [String] = [""] // Mindestens ein leeres Feld für Optionen
    @State private var selectedMeetingId: UUID? = nil // Ausgewählte Meeting-ID

    @ObservedObject var meetingManager: MeetingManager
    var onCreate: (GetVotingDTO) -> Void

    private let descriptionCharacterLimit = 300

    var body: some View {
        NavigationView {
            Form {
                // Meeting-Auswahl
                Section(header: Text("Meeting auswählen")) {
                    if !meetingManager.meetings.isEmpty {
                        Menu {
                            ForEach(meetingManager.meetings.filter { $0.status == .inSession }, id: \ .id) { meeting in
                                Button(action: {
                                    selectedMeetingId = meeting.id
                                }) {
                                    Text(meeting.name)
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedMeetingName())
                                    .foregroundColor(selectedMeetingId == nil ? .gray : .primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                        }
                    } else {
                        Text("Meetings werden geladen...")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                    
                    if meetingManager.meetings.filter({ $0.status == .inSession }).isEmpty {
                        Text("Keine aktiven Meetings verfügbar")
                            .foregroundColor(.red)
                            .font(.subheadline)
                    }
                }
                
                // Frage
                Section(header: Text("Frage")) {
                    TextField("Frage eingeben", text: $question)
                        .autocapitalization(.sentences)
                }
                
                // Beschreibung
                Section(header: Text("Beschreibung")) {
                    TextField("Beschreibung eingeben", text: $description)
                        .autocapitalization(.sentences)
                        .onChange(of: description) { _, newValue in
                            if newValue.count > descriptionCharacterLimit {
                                description = String(newValue.prefix(descriptionCharacterLimit))
                            }
                        }
                }
                
                // Anonyme Abstimmung
                Section(header: Text("Anonym")) {
                    Toggle("Anonyme Abstimmung", isOn: $anonymous)
                }
                
                // Optionen
                Section(header: Text("Optionen")) {
                    ForEach($options.indices, id: \.self) { index in
                        HStack {
                            TextField("Option \(index + 1)", text: $options[index])
                                .onChange(of: options[index]) { _, newValue in
                                    handleOptionChange(index: index, newValue: newValue)
                                }
                            
                            if options.count > 1 && index != 0 {
                                Button(action: {
                                    removeOption(at: index)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }





            }
            .navigationTitle("Neue Abstimmung")
            .navigationBarItems(
                leading: Button("Abbrechen") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Erstellen") {
                    createVoting()
                }
                .disabled(!isFormValid())
            )
            .onAppear {
                print("Meetings werden geladen...")
                meetingManager.fetchAllMeetings()
            }
        }
    }
    
    private func selectedMeetingName() -> String {
        if let meeting = meetingManager.meetings.first(where: { $0.id == selectedMeetingId }) {
            return meeting.name
        }
        return "Meeting auswählen"
    }
    
    private func createVoting() {
        guard let selectedMeetingId = selectedMeetingId else {
            print("Fehler: Kein Meeting ausgewählt")
            return
        }
        
        print("Ausgewählte Meeting-ID: \(selectedMeetingId)")
        
        let validOptions = options.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        print("Gültige Optionen: \(validOptions)")
        
        let optionDTOs = validOptions.enumerated().map { GetVotingOptionDTO(index: UInt8($0.offset + 1), text: $0.element) }
        print("OptionDTOs: \(optionDTOs)")
        
        let newVoting = CreateVotingDTO(
            meetingId: selectedMeetingId,
            question: question.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description,
            anonymous: anonymous,
            options: optionDTOs
        )
        
        print("CreateVotingDTO gesendet: \(newVoting)")
        
        VotingService.shared.createVoting(voting: newVoting) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let createdVoting):
                    print("Erstellung erfolgreich: \(createdVoting)")
                    onCreate(createdVoting)
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    print("Fehler beim Erstellen: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func isFormValid() -> Bool {
        let isValid = !question.trimmingCharacters(in: .whitespaces).isEmpty &&
        !options.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.isEmpty &&
        selectedMeetingId != nil
        print("Formular gültig: \(isValid)")
        return isValid
    }
    
    private func handleOptionChange(index: Int, newValue: String) {
        let trimmedValue = newValue.trimmingCharacters(in: .whitespaces)

        // Stelle sicher, dass ein leeres Feld existiert, wenn das aktuelle Feld befüllt wird
        if !trimmedValue.isEmpty && index == options.count - 1 {
            options.append("")
        }

        // Entferne alle leeren Felder außer das letzte, um die UI sauber zu halten
        if options.count > 1 {
            options = options.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty || options.last == "" }
        }
    }

    private func removeOption(at index: Int) {
        // Stelle sicher, dass mindestens ein Eingabefeld bleibt
        if options.count > 1 {
            options.remove(at: index)
        }
    }




}
