import SwiftUI
import MeetingServiceDTOs

struct EditMeetingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var meetingManager = MeetingManager()

    @State private var name: String
    @State private var description: String
    @State private var start: Date
    @State private var duration: String
    @State private var locationName: String
    @State private var locationStreet: String
    @State private var locationNumber: String
    @State private var locationLetter: String
    @State private var locationPostalCode: String
    @State private var locationPlace: String

    let meetingId: UUID

    init(meeting: GetMeetingDTO) {
        self.meetingId = meeting.id

        self._name = State(initialValue: meeting.name)
        self._description = State(initialValue: meeting.description ?? "")
        self._start = State(initialValue: meeting.start)
        self._duration = State(initialValue: meeting.duration != nil ? String(meeting.duration!) : "")
        self._locationName = State(initialValue: meeting.location?.name ?? "")
        self._locationStreet = State(initialValue: meeting.location?.street ?? "")
        self._locationNumber = State(initialValue: meeting.location?.number ?? "")
        self._locationLetter = State(initialValue: meeting.location?.letter ?? "")
        self._locationPostalCode = State(initialValue: meeting.location?.postalCode ?? "")
        self._locationPlace = State(initialValue: meeting.location?.place ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Details zur Sitzung")) {
                    TextField("Name der Sitzung", text: $name)
                    TextField("Beschreibung", text: $description)
                    DatePicker("Datum", selection: $start, displayedComponents: [.date, .hourAndMinute])
                    TextField("Dauer (in Minutes)", text: $duration)
                        .keyboardType(.numberPad)
                }

                Section(header: Text("Ort")) {
                    TextField("Name des Ortes", text: $locationName)
                    TextField("Straße", text: $locationStreet)
                    TextField("Nummer", text: $locationNumber)
                    TextField("Buchstabe", text: $locationLetter)
                    TextField("Postleitzahl", text: $locationPostalCode)
                    TextField("Stadt", text: $locationPlace)
                }
            }
            .navigationTitle("Sitzung bearbeiten")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        saveChanges()
                    }
                    .disabled(meetingManager.isLoading)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Löschen") {
                        deleteMeeting()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }

    private func saveChanges() {
        guard let durationUInt16 = UInt16(duration) else {
            meetingManager.errorMessage = "Invalid duration. Must be a number."
            return
        }

        guard !locationName.isEmpty else {
            meetingManager.errorMessage = "Location name cannot be empty."
            return
        }
        guard !name.isEmpty else {
            meetingManager.errorMessage = "Meeting name cannot be empty."
            return
        }

        let updatedLocation = CreateLocationDTO(
            name: locationName.isEmpty ? "Unnamed Location" : locationName,
            street: locationStreet.isEmpty ? "" : locationStreet,
            number: locationNumber.isEmpty ? "" : locationNumber,
            letter: locationLetter.isEmpty ? "" : locationLetter,
            postalCode: locationPostalCode.isEmpty ? "" : locationPostalCode,
            place: locationPlace.isEmpty ? "" : locationPlace
        )

        let patchDTO = PatchMeetingDTO(
            name: name.isEmpty ? "No Name Provided" : name,
            description: description.isEmpty ? "No Description Provided" : description,
            start: start,
            duration: durationUInt16,
            location: updatedLocation
        )

        meetingManager.updateMeeting(meetingId: meetingId, patchDTO: patchDTO) {
            dismiss()
        }
    }

    private func deleteMeeting() {
        //meetingManager.deleteMeeting(meetingId: meetingId)
        
        meetingManager.deleteMeeting(meetingId: meetingId) { result in
            switch result {
            case .success:
                // Meeting wurde erfolgreich gelöscht, navigiere zurück oder schließe die Ansicht
                dismiss()
            case .failure(let error):
                // Fehler beim Löschen des Meetings
                meetingManager.errorMessage = "Failed to delete meeting: \(error.localizedDescription)"
            }
        }
    }
}
