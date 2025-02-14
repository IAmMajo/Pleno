// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



import SwiftUI
import MeetingServiceDTOs

struct EditMeetingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var meetingManager = MeetingManager()

    
    // Variablen, um Sitzung zu bearbeiten
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

    // Wenn der User einen Ort über den Picker auswählt, wird diese Variable verändert
    @State private var selectedLocationID: UUID?
    
    // Der User kann entscheiden, ob er dem System einen neuen Ort hinzufügen möchte oder einen bestehenden Ort wählt.
    // Das geschieht in Abhängigkeit dieser Variable
    @State private var isAddingNewLocation = false
    
    @StateObject private var locationManager = LocationManager() // LocationManager verwenden, um bestehende Orte vom Server zu holen
    
    // MeetingId wird beim Aufruf der View mitgegeben
    let meetingId: UUID

    // Initialiser, damit die erstellten Variablen mit den bestehenden Werten befüllt werden
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
            // Formular, um Sitzung zu bearbeiten
            formView
            .navigationTitle("Sitzung bearbeiten")
            .toolbar {
                // Sitzung speichern
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        saveChanges()
                    }
                    .disabled(meetingManager.isLoading)
                }
                // Sitzung löschen
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Löschen") {
                        deleteMeeting()
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .onAppear(){
            locationManager.fetchLocations()
        }
    }

    private func saveChanges() {
        // Sicherstellen, dass die Dauer der Sitzung ein Int ist
        guard let durationUInt16 = UInt16(duration) else {
            return
        }

        // Sicherstellen, dass der Name des Ortes der Sitzung gesetzt ist
        guard !locationName.isEmpty else {
            return
        }
        
        // Sicherstellen, dass der Name der Sitzung gesetzt ist
        guard !name.isEmpty else {
            return
        }

        if isAddingNewLocation {
            // Wenn ein neuer Ort hinzugefügt wird
            guard !locationName.isEmpty else {
                meetingManager.errorMessage = "Location name is required for a new location."
                return
            }
        } else {
            // Wenn ein bestehender Ort ausgewählt wurde
            if let selectedLocation = locationManager.locations.first(where: { $0.id == selectedLocationID }) {
                locationName = selectedLocation.name
            } else {
                locationName = "" // Standardwert, wenn keine Location ausgewählt wurde
            }
        }
        
        // PatchMeetingDTO erstellen
        let patchDTO = PatchMeetingDTO(
            name: name.isEmpty ? "No Name Provided" : name,
            description: description.isEmpty ? "No Description Provided" : description,
            start: start,
            duration: durationUInt16,
            locationId: isAddingNewLocation ? nil : selectedLocationID,
            location: CreateLocationDTO(
                name: locationName,
                street: locationStreet,
                number: locationNumber,
                letter: locationLetter,
                postalCode: locationPostalCode,
                place: locationPlace
            )
        )

        // PatchMeetingDTO zum Server schicken, danach Sheet schließen
        meetingManager.updateMeeting(meetingId: meetingId, patchDTO: patchDTO) {
            dismiss()
        }
        dismiss()
    }

    // Sitzung löschen
    private func deleteMeeting() {
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

extension EditMeetingView {
    private var formView: some View {
        // Formular, um alle Variablen bearbeiten zu können
        Form {
            Section(header: Text("Details zur Sitzung")) {
                TextField("Name der Sitzung", text: $name)
                TextField("Beschreibung", text: $description)
                DatePicker("Datum", selection: $start, displayedComponents: [.date, .hourAndMinute])
                TextField("Dauer (in Minutes)", text: $duration)
                    .keyboardType(.numberPad)
            }

            placeSection
        }
    }
    private var placeSection: some View {
        VStack(alignment: .leading) {
            Toggle("Neuen Ort hinzufügen", isOn: $isAddingNewLocation)
                     
            // Wenn ein neuer Ort hinzugefügt werden soll, erscheinen Eingabefelder für Ort, Straße, Hausnummer, Buchstabe, Postleitzahl und Stadt
            if isAddingNewLocation {
                TextField("Name des Ortes", text: $locationName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                // Eingabefelder für einen neuen Ort
                TextField("Straße", text: $locationStreet)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack {
                    TextField("Hausnummer", text: $locationNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Buchstabe (optional)", text: $locationLetter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                TextField("Postleitzahl", text: $locationPostalCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Stadt", text: $locationPlace)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                // Wenn kein neuer Ort hinzugefügt werden soll
                // Auswahl eines bestehenden Ortes über den Picker
                if locationManager.isLoading {
                    ProgressView("Lade Orte...")
                } else if let errorMessage = locationManager.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                } else if locationManager.locations.isEmpty {
                    Text("Keine Orte verfügbar")
                        .foregroundColor(.gray)
                } else {
                    Picker("Name des Ortes", selection: $selectedLocationID) {
                        Text("Keine Auswahl").tag(nil as UUID?) // Option für "keine Auswahl"
                        
                        ForEach(locationManager.locations, id: \.id) { location in
                            Text(location.name).tag(location.id as UUID?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onAppear {
                        if let matchingLocation = locationManager.locations.first(where: { $0.name == locationName }) {
                            selectedLocationID = matchingLocation.id
                        }
                    }
                }
            }
        }
    }
    
}
