//
//  Posters_PositionView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 11.12.24.
//

import SwiftUI
import MeetingServiceDTOs
import PosterServiceDTOs

struct Posters_PositionView: View {
   let posterPosition: PosterPositionResponseDTO
    let image: Data
    let poster: PosterResponseDTO
    var posterManager: PosterManager
   
   func getDateColor(status: String) -> Color {
      switch status {
      case "hung":
         return .black.opacity(0.75)
      case "takenDown":
         return .black.opacity(0.75)
      case "notDisplayed":
         return .black.opacity(0.75)
      case "expiresInOneDay":
         return .orange
      case "expired":
         return .red
      default: return .black
      }
   
   }
   
    var body: some View {
       ScrollView {
             VStack {
                MapView()
                   .frame(height: 250)
                
                HStack {
                   Text("Abhängedatum:")
                      .foregroundStyle(.black.opacity(0.75))
                      .fontWeight(.semibold)
                      .padding(.trailing, -2)
                   
                   Text("\(DateTimeFormatter.formatDate(posterPosition.expiresAt))")
                      .fontWeight(.semibold)
                      .foregroundStyle(getDateColor(status: posterPosition.status))
                }.padding(.top, 10)
            
                 ResponsibleUsersList(users: posterPosition.responsibleUsers)
                
//                Form {
//                   Section {
//                      HStack {
//                          Text(position.longitude)
//                          Text(position.latitude)
//                         Spacer()
//                         VStack {
//                            Button(action: {  }) {
//                               Image(systemName: "map.fill")
//                            }
//                            .padding(.top, 10)
//                            Spacer()
//                         }
//                      }
//                   } header: {
//                      Text("Adresse in der Nähe")
//                   }
//                }
//                .scrollDisabled(true)
//                .frame(height: 180)
             }
       }
       .background(Color(UIColor.secondarySystemBackground))
       .toolbar {
           ToolbarItem(placement: .navigationBarTrailing) {
               Button(action: {
                   posterManager.deleteSignlePosterPosition(posterId: poster.id, positionId: posterPosition.id) {
                       print("Poster wurde erfolgreich gelöscht.")
                   }

               }) {
                   Image(systemName: "trash")
                       .foregroundColor(.red) // Setzt die Farbe der Mülltonne auf Rot
               }
           }
       }

    }

}
import SwiftUI

struct ResponsibleUsersList: View {
    let users: [ResponsibleUsersDTO]

    var body: some View {
        List {
            Section {
                ForEach(users, id: \.id) { user in
                    HStack {
                        Image(systemName: "person.crop.square.fill")
                            .resizable()
                            .frame(maxWidth: 40, maxHeight: 40)
                            .aspectRatio(1, contentMode: .fit)
                            .foregroundStyle(.gray.opacity(0.5))
                            .padding(.trailing, 5)

                        Text(user.name)
                    }
                }
            } header: {
                Text("Verantwortliche \(users.count)")
            }
        }
    }
}
