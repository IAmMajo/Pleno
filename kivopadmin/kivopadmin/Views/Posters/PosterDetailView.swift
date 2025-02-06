//
//  PosterDetailView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 10.12.24.
//

import SwiftUI
import PosterServiceDTOs
import CoreLocation

struct PosterDetailView: View {
    @StateObject private var posterManager = PosterManager() // MeetingManager als StateObject
    let poster: PosterResponseDTO


   
   
   func getDateColor(status: Status) -> Color {
      switch status {
      case .hung:
         return Color(UIColor.darkText)
      case .takenDown:
         return Color(UIColor.darkText)
      case .notDisplayed:
         return Color(UIColor.darkText)
      case .expiresInOneDay:
         return .orange
      case .expired:
         return .red
      }
   }
   
   func getDateStatusText(status: Status) -> String {
      switch status {
      case .hung:
         return "hängt"
      case .takenDown:
         return "abgehangen"
      case .notDisplayed:
         return "hängt nicht"
      case .expiresInOneDay:
         return "morgen überfällig"
      case .expired:
         return "überfällig"
      }
   }
   
    var body: some View {
        NavigationStack{
            VStack{
                if posterManager.isLoading {
                    ProgressView("Loading meetings...") // Ladeanzeige
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let errorMessage = posterManager.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else {
                    TopView(poster: poster, posterManager: posterManager)
                    MidView(poster: poster, posterManager: posterManager)
                }
            }
        }

       .onAppear {
           posterManager.fetchPosterPositions(poster: poster)
//           posterManager.fetchPosterPositionsToHang(poster: poster)
//           posterManager.fetchPosterPositionsTakendown(poster: poster)
//           posterManager.fetchPosterPositionsOverdue(poster: poster)
//           posterManager.fetchPosterPositionsHangs(poster: poster)
       }
       .toolbar {
           // Sammelposten hinzufügen
           ToolbarItem(placement: .navigationBarTrailing) {
               NavigationStack{
                   NavigationLink(destination: Posters_AddPositionView(poster: poster)){
                       Text("Plakatposition hinzufügen") // Symbol für Übersetzung (Weltkugel)
                           .foregroundColor(.blue) // Blaue Farbe für das Symbol
                   }
               }
           }
       }
    }
}

struct TopView: View {
    

    let poster: PosterResponseDTO
    let posterManager: PosterManager
    
    func getDateColor(status: Status) -> Color {
       switch status {
       case .hung:
          return Color(UIColor.darkText)
       case .takenDown:
          return Color(UIColor.darkText)
       case .notDisplayed:
          return Color(UIColor.darkText)
       case .expiresInOneDay:
          return .orange
       case .expired:
          return .red
       }
    }
    
    func getDateStatusText(status: Status) -> String {
       switch status {
       case .hung:
          return "hängt"
       case .takenDown:
          return "abgehangen"
       case .notDisplayed:
          return "hängt nicht"
       case .expiresInOneDay:
          return "morgen überfällig"
       case .expired:
          return "überfällig"
       }
    }
    
    var body: some View {
        HStack {
            if let uiImage = UIImage(data: poster.image) {
                Image(uiImage: uiImage)
                    .resizable() // Ermöglicht das Skalieren des Bildes
                    .aspectRatio(contentMode: .fit) // Beibehaltung des Seitenverhältnisses
                    .frame(maxWidth: 200, maxHeight: 200) // Begrenzung der Größe
                    .cornerRadius(8) // Abrunden der Ecken
                    .foregroundStyle(.gray.opacity(0.5)) // Graue Überlagerung (falls zutreffend)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous)) // Zuschneiden zu einer abgerundeten Form

                    
            }

            
            VStack{
                HStack{
                        Text("Abhängedatum:")
                           .fontWeight(.semibold)
                           .padding(.trailing, -2)
                    if let expirationPosition = posterManager.posterPositions.first?.expiresAt {
                           Text("\(DateTimeFormatter.formatDate(expirationPosition))")
                              .fontWeight(.semibold)
                              //.foregroundStyle(getDateColor(status: expirationPosition))
                        } else {
                           Text(DateTimeFormatter.formatDate(Date.now))
                              .fontWeight(.semibold)
                              .foregroundStyle(.red)
                    }
                 }.padding(.top, 5)
                VStack{
                      //CircularProgressView(value: 2, total: 3, status: Status.hung)
//                         .frame(maxWidth: 35, maxHeight: 35)
//                         .padding(.bottom, 5)
//                      Text("2/3")
//                         .font(.title3)
//                         .fontWeight(.semibold)
//                      Text("Aufgehangen")
//                         .font(.subheadline)
//                         .foregroundStyle(.black.opacity(0.6))
                   }
                   
                   VStack{
                      //CircularProgressView(value: 1, total: 4, status: Status.takenDown)
//                         .frame(maxWidth: 35, maxHeight: 35)
//                         .padding(.bottom, 5)
//                      Text("1/4")
//                         .font(.title3)
//                         .fontWeight(.semibold)
//                      Text("Abgehangen")
//                         .font(.subheadline)
//                         .foregroundStyle(.black.opacity(0.6))
                   }
            }
        }
    }
}

struct MidView: View {
    // Enum zur Definition der Status
    enum Status: String, CaseIterable, Identifiable {
        case all = "Alle"
        case toHang = "Bereit zum Aufhängen"
        case takendown = "Abgehangen"
        case overdue = "Überfällig"
        case hangs = "Aufgehangen"
        
        var id: String { self.rawValue } // Identifiable-Konformität
    }
    
    // Aktueller Status
    @State private var selectedStatus: Status = .all

    let poster: PosterResponseDTO
    let posterManager: PosterManager
    @State private var selectedPositions: Set<String> = []  // Set für ausgewählte Positionen
    
    var body: some View {
        // Picker-Komponente
        Picker("Select Status", selection: $selectedStatus) {
            // Iteriere über alle Status-Werte
            ForEach(Status.allCases) { status in
                Text(status.rawValue).tag(status) // Text und Tag für jeden Zustand
            }
        }
        .pickerStyle(SegmentedPickerStyle()) // Oder .menu, .wheel, etc.
        .padding()
//        Button(action: deleteSelectedPositions) {
//            Text("Ausgewählte löschen")
//                .foregroundColor(.red)
//        }
//        .padding()
//        .disabled(selectedPositions.isEmpty) // Button deaktivieren, wenn keine Auswahl getroffen
        List {
            Section(header: Text("Positionen")) {
                ForEach(filteredPositions, id: \.id) { position in
                    NavigationLink(destination: Posters_PositionView(posterPosition: position, image: poster.image, poster: poster, posterManager: posterManager)){
                        Text("Zur Plakat Position")
                    }
                }
            }
        }
    }
    
    private var filteredPositions: [PosterPositionResponseDTO] {
        switch selectedStatus {
        case .all:
            return posterManager.posterPositions
        case .toHang:
            return posterManager.posterPositions.filter { $0.status == .toHang }
        case .takendown:
            return posterManager.posterPositions.filter { $0.status == .takenDown }
        case .overdue:
            return posterManager.posterPositions.filter { $0.status == .overdue }
        case .hangs:
            return posterManager.posterPositions.filter { $0.status == .hangs }
        }
    }

    // Toggle-Auswahl für Positionen
    private func toggleSelection(for positionId: String) {
        if selectedPositions.contains(positionId) {
            selectedPositions.remove(positionId) // Abwählen
        } else {
            selectedPositions.insert(positionId) // Auswählen
        }
    }
    
    // Löschen der ausgewählten Positionen
    private func deleteSelectedPositions() {
        // Hier kannst du die Logik zum Löschen der Positionen hinzufügen
        //posterManager.deletePosterPosition(posterId: poster.id, positionIds: <#T##[UUID]#>, completion: <#T##() -> Void#>)
        selectedPositions.removeAll() // Nach dem Löschen die Auswahl zurücksetzen
    }
    



}


//#Preview {
////   @StateObject private var postersViewModel = PostersViewModel()
//
//   PosterDetailView(poster: mockPosters[0])
//}
