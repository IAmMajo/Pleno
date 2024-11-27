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
        VStack(spacing: 20) {
            Text("Create Meeting")
                .font(.largeTitle)
                .bold()

            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Group {
                        Text("Meeting Details")
                            .font(.headline)

                        TextField("Meeting Name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        TextField("Description (optional)", text: $description)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        DatePicker("Start Date", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(CompactDatePickerStyle())

                        TextField("Duration (minutes)", text: $duration)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    Divider()

                    Group {
                        Text("Location Details")
                            .font(.headline)

                        TextField("Location Name", text: $locationName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        TextField("Street (optional)", text: $locationStreet)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        HStack {
                            TextField("Number (optional)", text: $locationNumber)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            TextField("Letter (optional)", text: $locationLetter)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }

                        TextField("Postal Code (optional)", text: $locationPostalCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        TextField("Place (optional)", text: $locationPlace)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    Divider()

                    Button(action: saveMeeting) {
                        if meetingManager.isLoading {
                            ProgressView()
                        } else {
                            Text("Create Meeting")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(meetingManager.isLoading) // Button deaktivieren, wenn eine Anfrage läuft
                    .padding(.top, 20)

                    if let error = meetingManager.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding(.top, 10)
                    }
                }
                .padding()
            }
        }
        .padding()
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
