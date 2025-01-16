import SwiftUI
import PosterServiceDTOs
import PhotosUI

struct EventsMainView: View {
   @Environment(\.dismiss) var dismiss
   @State private var isEventSheetPresented = false // Zustand für das Sheet

   
   @State private var searchText = ""
    @State private var selectedTab = 0 // Zustand für den Picker
   
    var mockPosters: [Poster] {
       return [
          Poster(
             id: UUID(),
             posterPositionIds: [mockPosterPosition1.id, mockPosterPosition5.id, mockPosterPosition3.id, mockPosterPosition6.id],
             name: "Weihnachtsfeier",
             description: "Das ist das Plakat für unsere Weißnachtsfeier dieses Jahr und wir wollen versuchen so neue Mitglieder zu gewinnen.",
             imageBase64: "bild1"
          ),
          Poster(
             id: UUID(),
             posterPositionIds: [mockPosterPosition2.id, mockPosterPosition3.id],
             name: "Zirkus",
             description: "Das ist das Plakat für unseren Zirkus dieses Jahr und wir wollen versuchen so neue Mitglieder zu gewinnen.",
             imageBase64: "bild2"
          ),
          Poster(
             id: UUID(),
             posterPositionIds: [mockPosterPosition4.id],
             name: "Frühlingsfest",
             description: "Das ist das Plakat für unser Frühlingsfest dieses Jahr und wir wollen versuchen so neue Mitglieder zu gewinnen.",
             imageBase64: "bild3"
          ),
          Poster(
             id: UUID(),
             posterPositionIds: [mockPosterPosition3.id],
             name: "Herbstfest",
             description: "Das ist das Plakat für unser Herbstfest dieses Jahr und wir wollen versuchen so neue Mitglieder zu gewinnen.",
             imageBase64: "bild4"
          ),
       ]
    }
   
    var body: some View {

        NavigationStack {
            Picker("Termine", selection: $selectedTab) {
                Text("Aktuell").tag(0)
                Text("Archiviert").tag(1)
            }.padding()
            .pickerStyle(SegmentedPickerStyle()) // Optional: Stil ändern
            List {
                ForEach(mockPosters) { poster in
                    NavigationLink(destination: EmptyView()){
                        VStack(alignment: .leading) {
                            Text(poster.name)
                                .font(.headline)
                            Text("12.02.2025")
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
            EventErstellenView()
        }
    }
}


struct EventErstellenView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil // Optional Data für das Bild
    @State private var locationName: String = ""
    @State private var locationStreet: String = ""
    @State private var locationNumber: String = ""
    @State private var locationLetter: String = ""
    @State private var locationPostalCode: String = ""
    @State private var locationPlace: String = ""
    @State private var isAddingNewLocation = false
    @State private var selectedLocationID: UUID?
    
    @StateObject private var locationManager = LocationManager() // MeetingManager

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Allgemeine Informationen")) {
                    TextField("Titel", text: $title)
                    TextField("Beschreibung", text: $description)
                    
                }
                Section(header: Text("Location Details")) {
                    VStack(alignment: .leading) {
                        NavigationLink(destination: SelectPlaceView()){
                            Text("Ort auswählen")
                        }
                    }
                }
                

                
                

                Button(action: saveEvent) {
                    Text("Event erstellen")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
            .navigationTitle("Event erstellen")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {

                }
            }
        }
        .onAppear(){
            locationManager.fetchLocations()
        }
    }

    // Funktion zum Speichern des Sammelpostens
    private func saveEvent() {


        print("Sammelposten erstellt: ")
        dismiss()
    }
}


#Preview {
    EventsMainView()
}
