import SwiftUI
import PosterServiceDTOs
import PhotosUI
import MapKit

struct EventsMainView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isEventSheetPresented = false // Zustand für das Sheet
    @StateObject private var eventViewModel = EventViewModel()

   
    @State private var searchText = ""
    @State private var selectedTab = 0 // Zustand für den Picker
   
   
    var body: some View {

        NavigationStack {
            Picker("Termine", selection: $selectedTab) {
                Text("Aktuell").tag(0)
                Text("Archiviert").tag(1)
            }.padding()
            .pickerStyle(SegmentedPickerStyle()) // Optional: Stil ändern
            List {
                ForEach(eventViewModel.events, id: \.id) { event in
                    NavigationLink(destination: EventDetailView(eventId: event.id).environmentObject(eventViewModel)){
                        VStack(alignment: .leading) {
                            Text(event.name)
                                .font(.headline)
                            Text("Am \(DateTimeFormatter.formatDate(event.starts)) um \(DateTimeFormatter.formatTime(event.starts))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            //.searchable(text: $searchText, prompt: "durchsuchen")
            .toolbar {
                // Event hinzufügen
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isEventSheetPresented.toggle()
                    }) {
                        Text("Event erstellen") // Symbol für Übersetzung (Weltkugel)
                            .foregroundColor(.blue) // Blaue Farbe für das Symbol
                    }
                }
            }
            .navigationTitle("Events")
        }

        .sheet(isPresented: $isEventSheetPresented) {
            EventErstellenView().environmentObject(eventViewModel)
        }
        .onAppear(){
            eventViewModel.fetchEvents()
        }
    }
}





#Preview {
    EventsMainView()
}
