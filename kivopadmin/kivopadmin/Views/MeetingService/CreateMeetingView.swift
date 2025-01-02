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

    @Environment(\.dismiss) private var dismiss
    @StateObject private var meetingManager = MeetingManager() // MeetingManager verwenden
    @StateObject private var locationManager = LocationManager() // MeetingManager verwenden

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Meeting Details")) {
                    TextField("Meeting Name", text: $name)
                    
                    TextField("Description (optional)", text: $description)
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    
                    TextField("Duration (minutes)", text: $duration)
                        .keyboardType(.numberPad)
                }

                Section(header: Text("Location Details")) {
                    if locationManager.isLoading {
                        // Ladeanzeige während Daten geladen werden
                        ProgressView("Loading locations...")
                    } else if let errorMessage = locationManager.errorMessage {
                        // Fehleranzeige, wenn ein Fehler aufgetreten ist
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    } else if locationManager.locations.isEmpty {
                        // Nachricht, wenn keine Standorte gefunden wurden
                        Text("No locations available.")
                            .foregroundColor(.gray)
                    } else {
                        // Die Locations in einer Liste anzeigen
                        Picker("Location Name", selection: $selectedLocationID) {
                            ForEach(locationManager.locations, id: \.id) { location in
                                Text(location.name).tag(location.id as UUID?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle()) // Optional: Für Dropdown-Stil                    }
                    }
                    TextField("Street (optional)", text: $locationStreet)
                    
                    HStack {
                        TextField("Number (optional)", text: $locationNumber)
                        
                        TextField("Letter (optional)", text: $locationLetter)
                    }
                    
                    TextField("Postal Code (optional)", text: $locationPostalCode)
                    
                    TextField("Place (optional)", text: $locationPlace)
                }

                Section {
                    Button(action: saveMeeting) {
                        if meetingManager.isLoading {
                            ProgressView()
                        } else {
                            Text("Create Meeting")
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
            .navigationTitle("Create Meeting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear(){
            locationManager.fetchLocations()
        }
    }

    private func saveMeeting() {
        guard let durationUInt16 = UInt16(duration) else {
            meetingManager.errorMessage = "Invalid duration. Must be a number."
            return
        }
        
        if let selectedLocation = locationManager.locations.first(where: { $0.id == selectedLocationID }) {
            locationName = selectedLocation.name
        } else {
            locationName = "" // Standardwert, wenn keine Location ausgewählt wurde
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
            locationId: nil,
            location: location
        )

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

#Preview {
    CreateMeetingView()
}
