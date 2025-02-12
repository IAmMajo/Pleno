// This file is licensed under the MIT-0 License.

import SwiftUI
import MeetingServiceDTOs

struct CreateMeetingView: View {
    
    // Wenn der User einen Ort über den Picker auswählt, wird diese Variable verändert
    @State private var selectedLocationID: UUID?
    
    // Leere Variablen zum Erstellen einer Sitzung
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var startDate: Date = Date()
    @State private var duration: String = ""
    @State private var locationName: String = ""
    @State private var locationStreet: String = ""
    @State private var locationNumber: String = ""
    @State private var locationLetter: String = ""
    @State private var locationPostalCode: String = ""
    @State private var locationPlace: String = ""
    
    // Der User kann entscheiden, ob er dem System einen neuen Ort hinzufügen möchte oder einen bestehenden Ort wählt.
    // Das geschieht in Abhängigkeit dieser Variable
    @State private var isAddingNewLocation = false

    @Environment(\.dismiss) private var dismiss
    
    
    @EnvironmentObject private var meetingManager : MeetingManager // MeetingManager für alle Interaktionen mit dem Server im Bezug auf Sitzungen
    @StateObject private var locationManager = LocationManager() // LocationManager verwenden, um bestehende Orte vom Server zu holen

    var body: some View {
        NavigationStack {
            Form {
                // Details zur Sitzung werden bestimmt
                detailsSection
                Section(header: Text("Ort")) {
                    // Hier wird der Ort ausgewählt
                    placeSection
                }
                
                // Button zum speichern
                saveButton
            }
            .navigationTitle("Sitzung erstellen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Zurück") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear(){
            // alle bestehenden Orte werden aus vom Server geholt
            locationManager.fetchLocations()
        }
        .onDisappear(){
            // Wenn der User diese View verlässt, werden alle Sitzungen geladen
            meetingManager.fetchAllMeetings()
        }
    }

    // Funktion zum speichern einer Sitzung
    private func saveMeeting() {
        
        // stellt sicher, dass der User eine Zahl eingegeben hat
        guard let durationUInt16 = UInt16(duration) else {
            meetingManager.errorMessage = "Invalid duration. Must be a number."
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

        // CreateLocationDTO wird befüllt
        let location = CreateLocationDTO(
            name: locationName,
            street: locationStreet.isEmpty ? nil : locationStreet,
            number: locationNumber.isEmpty ? nil : locationNumber,
            letter: locationLetter.isEmpty ? nil : locationLetter,
            postalCode: locationPostalCode.isEmpty ? nil : locationPostalCode,
            place: locationPlace.isEmpty ? nil : locationPlace
        )

        // CreateMeetingDTO wird befüllt
        let meeting = CreateMeetingDTO(
            name: name,
            description: description.isEmpty ? nil : description,
            start: startDate,
            duration: durationUInt16,
            locationId: isAddingNewLocation ? nil : selectedLocationID,
            location: location//isAddingNewLocation ? location : nil
        )

        // Meeting über MeetingManager erstellen
        meetingManager.createMeeting(meeting)
        
        // Formular wird geleert
        clearForm()
        
        // Sheet schließen
        dismiss()
    }


    private func clearForm() {
        name = ""
        description = ""
        startDate = Date()
        duration = ""
        locationName = ""
        locationStreet = ""
        locationNumber = ""
        locationLetter = ""
        locationPostalCode = ""
        locationPlace = ""
        meetingManager.errorMessage = nil
    }
}


extension CreateMeetingView {
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
                }
            }
        }
    }
    
    // Button um Sitzung zu speichern
    private var saveButton: some View {
        Section{
            Button(action: saveMeeting) {
                if meetingManager.isLoading {
                    ProgressView()
                } else {
                    Text("Sitzung erstellen")
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(meetingManager.isLoading)

            if let error = meetingManager.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var detailsSection: some View {
        Section(header: Text("Details zur Sitzung")) {
            TextField("Name der Sitzung", text: $name)
            
            TextField("Beschreibung (optional)", text: $description)
            
            DatePicker("Datum", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
            
            TextField("Dauer (in Minuten)", text: $duration)
                .keyboardType(.numberPad)
        }
    }
}
