import SwiftUI
import MeetingServiceDTOs

struct CreateMeetingView: View {
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
                    TextField("Location Name", text: $locationName)
                    
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
    }

    private func saveMeeting() {
        guard let durationUInt16 = UInt16(duration) else {
            meetingManager.errorMessage = "Invalid duration. Must be a number."
            return
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
