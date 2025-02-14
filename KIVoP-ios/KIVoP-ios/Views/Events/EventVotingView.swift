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

//
//  EventVotingView.swift
//  KIVoP-ios
//
//  Created by Christian Heller on 18.01.25.
//

import SwiftUI
import MapKit
import CoreLocation
import RideServiceDTOs

struct EventVotingView: View {
    @State private var address = "Datteln, Deutschland"
    var eventID: UUID
    @State private var details: GetEventDetailDTO?
    let baseURL = "https://kivop.ipv64.net"
    @State private var selectedLocation: CLLocationCoordinate2D?
    var event: GetEventDTO

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                EventDateSection(details: details)
                EventDescriptionSection(details: details)
                EventLocationSection(address: $address, selectedLocation: $selectedLocation, details: details)
                CarpoolSection(event: event)
                ParticipationSection(details: details, onParticipate: createParticipation, onUpdateParticipation: patchParticipation)
                ParticipantListSection(details: details)
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGray5).edgesIgnoringSafeArea(.all))
        .navigationTitle(details?.name ?? "Event Name")
        .onAppear {
            fetchEventDetails(eventID: event.id)
            updateSelectedLocation()
        }
    }

    // MARK: - Helper Methods
    func fetchEventDetails(eventID: UUID) {
        guard let url = URL(string: "\(baseURL)/events/\(eventID)") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Unauthorized: No token found")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received from server")
                return
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let decodedEventDetails = try decoder.decode(GetEventDetailDTO.self, from: data)
                DispatchQueue.main.async {
                    self.details = nil
                    self.details = decodedEventDetails
                    updateSelectedLocation() // Make sure location is updated after details are fetched
                }
            } catch {
                print("JSON Decode Error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func updateSelectedLocation() {
        if let latitude = details?.latitude, let longitude = details?.longitude {
            selectedLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
            fetchAddress(from: selectedLocation)
        }
    }
    
    func fetchAddress(from location: CLLocationCoordinate2D?) {
        guard let location = location else { return }
        let geocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        geocoder.reverseGeocodeLocation(clLocation) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                var address = ""
                if let street = placemark.thoroughfare {
                    address += street
                }
                if let postalCode = placemark.postalCode {
                    address += ",\(postalCode)"
                }
                if let city = placemark.locality {
                    address += " \(city)"
                }
                if let country = placemark.country {
                    address += ",\(country)"
                }
                DispatchQueue.main.async {
                    self.address = address
                }
            }
        }
    }
    
    func createParticipation(_ dto: CreateEventParticipationDTO) {
            guard let url = URL(string: "\(baseURL)/events/\(eventID)/participations") else {
                print("Invalid URL")
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if let token = UserDefaults.standard.string(forKey: "jwtToken") {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                print("Unauthorized: No token found")
                return
            }

            do {
                let jsonData = try JSONEncoder().encode(dto)
                request.httpBody = jsonData
            } catch {
                print("JSON Encode Error: \(error.localizedDescription)")
                return
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                    print("Participation updated successfully")
                    DispatchQueue.main.async {
                        fetchEventDetails(eventID: event.id)
                    }
                } else {
                    print("Failed to update participation")
                }
            }.resume()
        }
    func patchParticipation(_ dto: PatchEventParticipationDTO) {
            guard let participant = details?.participations.first(where: { $0.itsMe }) else {
                print("No valid participant found")
                return
            }
            let participantID = participant.id
            
            guard let url = URL(string: "\(baseURL)/events/participations/\(participantID)") else {
                print("Invalid URL")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if let token = UserDefaults.standard.string(forKey: "jwtToken") {
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            } else {
                print("Unauthorized: No token found")
                return
            }

            do {
                let jsonData = try JSONEncoder().encode(dto)
                request.httpBody = jsonData
            } catch {
                print("JSON Encode Error: \(error.localizedDescription)")
                return
            }

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("Participation status updated successfully")
                    DispatchQueue.main.async {
                        fetchEventDetails(eventID: event.id)
                    }
                } else {
                    print("Failed to update participation status")
                }
            }.resume()
        }
    }

// MARK: - Subviews
struct EventDateSection: View {
    let details: GetEventDetailDTO?

    var body: some View {
        if let starts = details?.starts {
            Text("\(DateTimeFormatter.formatDate(starts)) - \(DateTimeFormatter.formatTime(starts))")
                .fontWeight(.bold)
                .padding(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.black, lineWidth: 1)
                )
        }
    }
}

struct EventDescriptionSection: View {
    let details: GetEventDetailDTO?

    var body: some View {
        if let description = details?.description {
            Text(description)
                .font(.body)
                .padding(.horizontal)
        }
    }
}

struct EventLocationSection: View {
    @Binding var address: String
    @Binding var selectedLocation: CLLocationCoordinate2D?
    let details: GetEventDetailDTO?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Ort")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack(spacing: 0) { // No spacing between the elements
                EventLocationView(selectedLocation: $selectedLocation)
                    .frame(height: 150)
                    .cornerRadius(12)

                AddressBox(address: $address)
                    .frame(height: 150) // Ensures AddressBox takes the same height
            }
        }
        .padding(.horizontal)
    }
}

struct AddressBox: View {
    @Binding var address: String

    var body: some View {
        VStack {
            // Split the address into words and display each on a new line
            ForEach(address.split(separator: ","), id: \.self) { word in
                Text(String(word))
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .padding(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true) // Ensures the word breaks correctly
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(8)
        .lineLimit(nil) // Allows unlimited lines for text
    }
}



struct CarpoolSection: View {
    let event: GetEventDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Fahrgemeinschaft")
                .font(.subheadline)
                .foregroundColor(.gray)
            NavigationLink(destination: EventRideView(viewModel: EventRideViewModel(event: event))) {
                Text("Fahrgemeinschaften ansehen")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }
}

struct ParticipationSection: View {
    let details: GetEventDetailDTO?
    let onParticipate: (CreateEventParticipationDTO) -> Void
    let onUpdateParticipation: (PatchEventParticipationDTO) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Willst du an dem Event teilnehmen?")
                .font(.body)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 50) {
                ActionButton(title: "Ja", color: .blue) {
                    if (details?.participations.first(where: { $0.itsMe })) != nil {
                        onUpdateParticipation(PatchEventParticipationDTO(participates: true))
                    } else {
                        onParticipate(CreateEventParticipationDTO(participates: true))
                    }
                }
                ActionButton(title: "Nein", color: .gray) {
                    if (details?.participations.first(where: { $0.itsMe })) != nil {
                        onUpdateParticipation(PatchEventParticipationDTO(participates: false))
                    } else {
                        onParticipate(CreateEventParticipationDTO(participates: false))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            ParticipationStats(details: details)
        }
        .padding(.horizontal)
    }
}

struct ParticipationStats: View {
    let details: GetEventDetailDTO?

    var body: some View {
        if let participations = details?.participations {
            let confirmedCount = participations.filter { $0.participates == .present }.count
            let declinedCount = participations.filter { $0.participates == .absent }.count

            HStack(spacing: 80) {
                StatView(count: confirmedCount, icon: "person.fill.checkmark", color: .blue)
                StatView(count: declinedCount, icon: "person.fill.xmark", color: .orange)
            }
        }
    }
}

struct StatView: View {
    let count: Int
    let icon: String
    let color: Color

    var body: some View {
        VStack {
            Text("\(count)")
                .font(.title)
                .fontWeight(.bold)
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(color)
        }
    }
}

struct ActionButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            Text(title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color)
                .cornerRadius(8)
        }
        .frame(width: 100)
    }
}

struct ParticipantListSection: View {
    let details: GetEventDetailDTO?

    var body: some View {
        if let participations = details?.participations {
            VStack(alignment: .leading, spacing: 10) {
                Text("Mitglieder")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                ForEach(participations, id: \.id) { participation in
                    HStack {
                        Text(participation.name)
                            .font(.body)
                            .fontWeight(participation.itsMe ? .bold : .regular)
                        Spacer()
                        Image(systemName: participation.participates == .present ? "checkmark.circle" : "xmark.circle")
                            .foregroundColor(participation.participates == .present ? .blue : .red)
                            .font(.system(size: 18))
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

//struct EventVotingView_Previews: PreviewProvider {
//    static var previews: some View {
//        EventVotingView()
//    }
//}
