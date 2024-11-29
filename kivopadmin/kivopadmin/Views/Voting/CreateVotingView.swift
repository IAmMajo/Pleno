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
    
    var body: some View {
        NavigationView {
            Form {
                // Meeting-Auswahl
                Section(header: Text("Meeting auswählen")) {
                    if !meetingManager.meetings.isEmpty {
                        Picker("Meeting", selection: $selectedMeetingId) {
                            ForEach(meetingManager.meetings.filter { $0.status == .inSession }, id: \.id) { meeting in
                                Text(meeting.name).tag(meeting.id as UUID?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
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
                        .onChange(of: question) { newValue in
                            print("Frage aktualisiert: \(newValue)")
                        }
                }
                
                // Beschreibung
                Section(header: Text("Beschreibung")) {
                    TextField("Beschreibung eingeben", text: $description)
                        .autocapitalization(.sentences)
                        .onChange(of: description) { newValue in
                            print("Beschreibung aktualisiert: \(newValue)")
                        }
                }
                
                // Anonyme Abstimmung
                Section(header: Text("Anonym")) {
                    Toggle("Anonyme Abstimmung", isOn: $anonymous)
                        .onChange(of: anonymous) { newValue in
                            print("Anonyme Abstimmung: \(newValue)")
                        }
                }
                
                // Optionen
                Section(header: Text("Optionen")) {
                    ForEach($options.indices, id: \.self) { index in
                        TextField("Option \(index + 1)", text: $options[index])
                            .onChange(of: options[index]) { newValue in
                                print("Option \(index + 1) aktualisiert: \(newValue)")
                            }
                    }
                    .onDelete { indexSet in
                        options.remove(atOffsets: indexSet)
                        if options.isEmpty { options.append("") }
                        print("Aktuelle Optionen: \(options)")
                    }
                    Button(action: { options.append("") }) {
                        Label("Option hinzufügen", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Neue Umfrage")
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
    
    private func createVoting() {
        guard let selectedMeetingId = selectedMeetingId else {
            print("Fehler: Kein Meeting ausgewählt")
            return
        }
        
        print("Ausgewählte Meeting-ID: \(selectedMeetingId)")
        
        let validOptions = options.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        print("Gültige Optionen: \(validOptions)")
        
        let optionDTOs = validOptions.enumerated().map { GetVotingOptionDTO(index: UInt8($0.offset), text: $0.element) }
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
}
