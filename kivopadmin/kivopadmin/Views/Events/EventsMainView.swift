import SwiftUI
import PosterServiceDTOs
import PhotosUI
import MapKit
import RideServiceDTOs

struct EventsMainView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isEventSheetPresented = false // Zustand für das Sheet
    @StateObject private var eventViewModel = EventViewModel()

   
    @State private var searchText = ""
    @State private var selectedTab = 0 // Zustand für den Picker
    
    @State private var eventToDelete: GetEventDTO? // Temporäre Variable für das zu löschende Event
    @State private var showDeleteConfirmation = false   // Zeigt den Bestätigungsdialog an
   
    var filteredEvents: [GetEventDTO] {
        switch selectedTab {
        case 0: // Aktuell
            return eventViewModel.events.filter { $0.ends > Date() }
        case 1: // Archiviert
            return eventViewModel.events.filter { $0.ends <= Date() }
        default:
            return eventViewModel.events
        }
    }

   
    var body: some View {
        NavigationStack {
            Picker("Termine", selection: $selectedTab) {
                Text("Aktuell").tag(0)
                Text("Archiviert").tag(1)
            }.padding()
            .pickerStyle(SegmentedPickerStyle()) // Optional: Stil ändern
            EventListView(
                eventViewModel: eventViewModel,
                eventToDelete: $eventToDelete,
                showDeleteConfirmation: $showDeleteConfirmation,
                filteredEvents: filteredEvents
            )
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

struct EventRow: View {
    let event: GetEventDTO

    var body: some View {
        VStack(alignment: .leading) {
            Text(event.name)
                .font(.headline)
            Text("Am \(DateTimeFormatter.formatDate(event.starts)) um \(DateTimeFormatter.formatTime(event.starts))")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

struct EventListView: View {
    @ObservedObject var eventViewModel: EventViewModel
    @Binding var eventToDelete: GetEventDTO? // Binding für das zu löschende Event
    @Binding var showDeleteConfirmation: Bool // Binding für den Lösch-Alert

    var filteredEvents: [GetEventDTO] // Gefilterte Events (aktuell/archiviert)

    var body: some View {
        List {
            ForEach(filteredEvents, id: \.id) { event in
                NavigationLink(destination: EventDetailView(eventId: event.id).environmentObject(eventViewModel)) {
                    EventRow(event: event)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        confirmDelete(event: event)
                    } label: {
                        Text("Löschen")
                    }
                    .tint(.red)
                }
            }
        }
        .alert("Event löschen?", isPresented: $showDeleteConfirmation, actions: {
            Button("Löschen", role: .destructive, action: deleteConfirmed)
            Button("Abbrechen", role: .cancel, action: { eventToDelete = nil })
        }, message: {
            if let eventName = eventToDelete?.name {
                Text("Möchtest du das Event '\(eventName)' wirklich löschen?")
            }
        })
    }

    private func confirmDelete(event: GetEventDTO) {
        eventToDelete = event
        showDeleteConfirmation = true
    }

    private func deleteConfirmed() {
        if let event = eventToDelete {
            eventViewModel.deleteEvent(eventId: event.id) {
                DispatchQueue.main.async {
                    eventViewModel.fetchEvents()
                }
            }
        }
        eventToDelete = nil
    }
}


