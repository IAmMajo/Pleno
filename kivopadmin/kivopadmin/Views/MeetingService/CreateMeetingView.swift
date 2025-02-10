import SwiftUI
import MeetingServiceDTOs

struct CreateMeetingView: View {
    @State private var selectedLocationID: UUID?
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
    @State private var isAddingNewLocation = false

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var meetingManager : MeetingManager
    @StateObject private var locationManager = LocationManager() // MeetingManager verwenden

    var body: some View {
        NavigationStack {
            Form {
                detailsSection
                Section(header: Text("Ort")) {
                    placeSection
                }
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
            locationManager.fetchLocations()
        }
        .onDisappear(){
            meetingManager.fetchAllMeetings()
        }
    }

    private func saveMeeting() {
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

        let location = CreateLocationDTO(
            name: locationName,
            street: locationStreet.isEmpty ? nil : locationStreet,
            number: locationNumber.isEmpty ? nil : locationNumber,
            letter: locationLetter.isEmpty ? nil : locationLetter,
            postalCode: locationPostalCode.isEmpty ? nil : locationPostalCode,
            place: locationPlace.isEmpty ? nil : locationPlace
        )

        let meeting = CreateMeetingDTO(
            name: name,
            description: description.isEmpty ? nil : description,
            start: startDate,
            duration: durationUInt16,
            locationId: isAddingNewLocation ? nil : selectedLocationID,
            location: location//isAddingNewLocation ? location : nil
        )
        print(meeting)

        // Meeting über MeetingManager erstellen
        meetingManager.createMeeting(meeting)
        clearForm()
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
                // Auswahl eines bestehenden Ortes über den Picker
                if locationManager.isLoading {
                    ProgressView("Loading locations...")
                } else if let errorMessage = locationManager.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                } else if locationManager.locations.isEmpty {
                    Text("No locations available.")
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
