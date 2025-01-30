//
//  EventView.swift
//  KIVoP-ios
//
//  Created by Christian Heller on 17.01.25.
//

import SwiftUI
import RideServiceDTOs

struct EventView: View {
    @State private var searchText = ""
    @State private var selectedGroup = "Aktuelle"
    @State private var events: [GetEventDTO] = []
    let baseURL = "https://kivop.ipv64.net"
    let currentDate = Date()
    
    var filteredEvents: [GetEventDTO] {
        events
            .filter {
                searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
            }
            .filter {
                selectedGroup == "Aktuelle"
                    ? $0.starts >= currentDate
                    : $0.starts < currentDate
            }
            .sorted { $0.starts < $1.starts }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Suchleiste
                HStack {
                    TextField("Suchen", text: $searchText)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .overlay(
                            HStack {
                                Spacer()
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        )
                }
                .padding()
                .background(Color.white)
                
                // Gruppenschalter
                Picker("", selection: $selectedGroup) {
                    Text("Aktuelle").tag("Aktuelle")
                    Text("Vergangene").tag("Vergangene")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Event-Liste
                List(filteredEvents, id: \.id) { event in
                    NavigationLink(destination: EventVotingView(eventID: event.id)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(event.name)
                                    .font(.headline)
                                Text(dateFormatter.string(from: event.starts))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .background(Color.gray.opacity(0.1))
            }
            .background(Color.gray.opacity(0.1))
            .navigationTitle("Events")
            .onAppear{
                fetchEvents()
            }
        }
    }
    
    // Fetch Events für die Auswahl im Array
    func fetchEvents() {
        guard let url = URL(string: "\(baseURL)/events") else {
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
                // Decodieren der Antwort in ein Array von GetSpecialRideDTO
                let decodedEvents = try decoder.decode([GetEventDTO].self, from: data)
                print(decodedEvents)
                
                // Sicherstellen, dass die Updates im Main-Thread ausgeführt werden
                DispatchQueue.main.async {
                self.events = []
                self.events = decodedEvents // Array mit den Sonderfahrten speichern
                }
            } catch {
                print("JSON Decode Error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
}

//struct EventView_Previews: PreviewProvider {
//    static var previews: some View {
//        EventView()
//    }
//}
