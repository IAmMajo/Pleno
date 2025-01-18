//
//  PosterDetailView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 10.12.24.
//

import SwiftUI
import PosterServiceDTOs

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

       .refreshable {
       }
       .onAppear {
           posterManager.fetchPosterPositions(poster: poster)
           posterManager.fetchPosterPositionsToHang(poster: poster)
           posterManager.fetchPosterPositionsTakendown(poster: poster)
           posterManager.fetchPosterPositionsOverdue(poster: poster)
           posterManager.fetchPosterPositionsHangs(poster: poster)
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
            AsyncImage(url: URL(string: "https://kivop.ipv64.net/posters/images/posters/\(poster.imageUrl)")) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(maxWidth: 200, maxHeight: 200)
            .aspectRatio(contentMode: .fit)
            .cornerRadius(8)
            .foregroundStyle(.gray.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            
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
                      CircularProgressView(value: 2, total: 3, status: Status.hung)
                         .frame(maxWidth: 35, maxHeight: 35)
                         .padding(.bottom, 5)
                      Text("2/3")
                         .font(.title3)
                         .fontWeight(.semibold)
                      Text("Aufgehangen")
                         .font(.subheadline)
                         .foregroundStyle(.black.opacity(0.6))
                   }
                   
                   VStack{
                      CircularProgressView(value: 1, total: 4, status: Status.takenDown)
                         .frame(maxWidth: 35, maxHeight: 35)
                         .padding(.bottom, 5)
                      Text("1/4")
                         .font(.title3)
                         .fontWeight(.semibold)
                      Text("Abgehangen")
                         .font(.subheadline)
                         .foregroundStyle(.black.opacity(0.6))
                   }
            }
        }
    }
}

struct MidView: View {
    

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
        List {
            Section(header: Text("Positionen")) {
                ForEach(posterManager.posterPositions, id: \.id) { position in
                    Text("Test") // Zugriff auf ein Property des Elements
                }
            }
        }
    }
}


//#Preview {
////   @StateObject private var postersViewModel = PostersViewModel()
//
//   PosterDetailView(poster: mockPosters[0])
//}
