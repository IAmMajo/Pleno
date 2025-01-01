//
//  PosterDetailView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 10.12.24.
//

import SwiftUI

struct PosterDetailView: View {
   
   let poster: Poster
   var posterPositions: [PosterPosition] {
      return getPosterPositions(poster: mockPosters[0])
   }
   
   @StateObject private var postersViewModel = PostersViewModel()
   
   @State private var isLoading = false
   @State private var error: String?
   
   @State var optionTextMap: [UInt8: String] = [:]
   
   let addresses = [
           "Am Grabstein 6, Transilvanien",
           "Hinter der Obergasse 27, am Obergipfelzelt hinter Neuss",
           "Baumhaus 5, Wald",
           "Katerstraße 3, Schnurrdorf"
       ]
   
   private func getPosterPositions(poster: Poster) -> [PosterPosition] {
      var posterPositions: [PosterPosition] = []
      for id in poster.posterPositionIds {
         posterPositions.append(mockPosterPositions.first { $0.id == id }!)
      }
      return posterPositions
   }
   
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
       ScrollView {
             VStack {
                Divider()
                
                HStack {
                   Text("Abhängedatum:")
                      .fontWeight(.semibold)
                      .padding(.trailing, -2)
                   let poster = mockPosters[0]
                   if let expirationPosition = postersViewModel.posterExpiresPositions[poster.id!] {
                      Text("\(DateTimeFormatter.formatDate(expirationPosition.expiresAt))")
                         .fontWeight(.semibold)
                         .foregroundStyle(getDateColor(status: expirationPosition.status))
                   } else {
//                      Text("Nicht verfügbar")
//                         .fontWeight(.semibold)
                      Text(DateTimeFormatter.formatDate(Date.now))
                         .fontWeight(.semibold)
                         .foregroundStyle(.red)
                   }
                }.padding(.top, 5)
                
                Image("TestPosterImage")
                   .resizable()
                   .aspectRatio(contentMode: .fit)
                   .frame(maxWidth: 200, maxHeight: 200)
                   .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                   .foregroundStyle(.gray.opacity(0.5))
                   .padding(.top, 10) .padding(.bottom, 10)
                
                HStack{
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
                   .padding(.leading, 50)
                   
                   Spacer()
                   
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
                   .padding(.trailing, 50)
                }
                
                Form {
                   Section {
                      Text("\(poster.description)")
                   } header: {
                      Text("Beschreibung")
                   }
                }
                .scrollDisabled(true)
                .frame(height: 150)
                
                List{
                   Section {
                      ForEach (posterPositions.indices, id: \.self) { index in
                         let position = posterPositions[index]
                         let address = addresses[index].components(separatedBy: ", ")[0]
                         NavigationLink(destination: Posters_PositionView(position: position).navigationTitle("\(address)")) {
                            HStack {
                               VStack {
                                  Text(addresses[index])
                                     .frame(maxWidth: .infinity, alignment: .leading)
                                  
                                  Text("\(DateTimeFormatter.formatDate(position.expiresAt))")
                                     .frame(maxWidth: .infinity, alignment: .leading)
                                     .font(.callout)
                                     .foregroundStyle(getDateColor(status: position.status))
                                  
                               }
                               Spacer()
                               Text(getDateStatusText(status: position.status))
                                  .font(.caption)
                                  .opacity(0.6)
                            }
                         }
                      }
                   } header: {
                       
                       HStack{
                           Text("Standorte (3)")
                           NavigationLink(destination: Posters_AddPositionView()) {
                               Text("+ Hinzufügen").foregroundStyle(.blue)
                           }
                           Spacer()
                       }
                    
                   }
                }
                .frame(height: CGFloat((poster.posterPositionIds.count * 100) + (poster.posterPositionIds.count < 4 ? 200 : 0)), alignment: .top)
                //             .scrollContentBackground(.hidden)
                .environment(\.defaultMinListHeaderHeight, 10)
             }
       }
       .refreshable {
       }
       .navigationBarTitleDisplayMode(.inline)
       .background(Color(UIColor.secondarySystemBackground))
       .onAppear {
          Task {

          }
       }
    }
}

#Preview {
//   @StateObject private var postersViewModel = PostersViewModel()

   PosterDetailView(poster: mockPosters[0])
}
