//
//  EventVotingView.swift
//  KIVoP-ios
//
//  Created by Christian Heller on 18.01.25.
//

import SwiftUI
import MapKit
import RideServiceDTOs

struct EventVotingView: View {
    
//    @State private var address = "Kamp-Lintfort, Germany"
    var eventID: UUID
    @State private var details: GetEventDetailDTO?
    let baseURL = "https://kivop.ipv64.net"
    @State private var selectedLocation: CLLocationCoordinate2D?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Event Date
                if details != nil {
                    Text(DateTimeFormatter.formatDate(details!.starts))
                        .fontWeight(.bold)
                    
                    // Description
                    Text((details?.description)!)
                        .font(.body)
                        .padding(.horizontal)
                    
                    // Location Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ort")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                                            HStack(spacing: 20) {
                                                // Map View
                                                EventLocationView(selectedLocation:$selectedLocation)
                                                    .frame(height: 150)
                                                    .cornerRadius(12)
                        
                        // Address Box
                        //                        VStack {
                        //                            Text("Adresse")
                        //                                .font(.subheadline)
                        //                                .foregroundColor(.gray)
                        //                                .padding(.bottom, 5)
                        //
                        //                            Text(address)
                        //                                .font(.body)
                        //                                .multilineTextAlignment(.leading)
                        //                                .padding()
                        //                                .frame(maxWidth: .infinity, alignment: .leading)
                        //                                .background(Color(UIColor.systemGray6))
                        //                                .cornerRadius(8)
                        //                        }
                            .frame(width: 150)
                            }
                    }
                    .padding(.horizontal)
                    
                    // Carpool Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Fahrgemeinschaft")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            print("Fahrgemeinschaften ansehen")
                        }) {
                            Text("Fahrgemeinschaften ansehen")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Participation Section
                    VStack(spacing: 20) {
                        Text("Willst du an dem Event teilnehmen?")
                            .font(.body)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 50) {
                            Button(action: {
                                print("Ja")
                            }) {
                                Text("Ja")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            .frame(width: 100)
                            
                            Button(action: {
                                print("Nein")
                            }) {
                                Text("Nein")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray)
                                    .cornerRadius(8)
                            }
                            .frame(width: 100)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(spacing: 10) {
                            HStack(spacing: 80) {
                                VStack {
                                    Text("0")
                                        .font(.title)
                                        .fontWeight(.bold)
                                    
                                    Image(systemName: "person.fill.checkmark")
                                        .font(.largeTitle)
                                        .foregroundColor(.blue)
                                }
                                
                                VStack {
                                    Text("1")
                                        .font(.title)
                                        .fontWeight(.bold)
                                    
                                    Image(systemName: "person.fill.questionmark")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                }
                                
                                VStack {
                                    Text("0")
                                        .font(.title)
                                        .fontWeight(.bold)
                                    
                                    Image(systemName: "person.fill.xmark")
                                        .font(.largeTitle)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Members Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Mitglieder")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            print("Mitglied gedrückt")
                        }) {
                            Text("Person 1")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGray5).edgesIgnoringSafeArea(.all))
        .navigationTitle(details?.name ?? "Event Name")
        .onAppear{
            fetchEventDetails(eventID: eventID)
            if details?.latitude != nil && details?.longitude != nil {
                selectedLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(details!.latitude), longitude: CLLocationDegrees(details!.longitude))
            }
        }
    }
    
    func fetchEventDetails(eventID: UUID) {
        guard let url = URL(string: "\(baseURL)/events/\(eventID)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Füge JWT Token zu den Headern hinzu
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Unauthorized: No token found")
            return
        }
        
        // Führe den Netzwerkaufruf aus
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
                // Decodieren der Antwort in ein Array von GetEventDetailDTO
                let decodedEventDetails = try decoder.decode(GetEventDetailDTO.self, from: data)
                print(decodedEventDetails)
                
                DispatchQueue.main.async {
                    self.details = decodedEventDetails
                }
            } catch {
                print("JSON Decode Error: \(error.localizedDescription)")
            }
        }.resume()
    }
}

//struct EventVotingView_Previews: PreviewProvider {
//    static var previews: some View {
//        EventVotingView()
//    }
//}
