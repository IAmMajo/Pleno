//
//  Posters_PositionView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 11.12.24.
//

import SwiftUI
import MeetingServiceDTOs

struct Posters_PositionView: View {
   let position: PosterPosition
   
   func getDateColor(status: Status) -> Color {
      switch status {
      case .hung:
         return .black.opacity(0.75)
      case .takenDown:
         return .black.opacity(0.75)
      case .notDisplayed:
         return .black.opacity(0.75)
      case .expiresInOneDay:
         return .orange
      case .expired:
         return .red
      }
   }
   
    var body: some View {
       ScrollView {
             VStack {
                MapView()
                   .frame(height: 250)
                
                CircleImageView(status: position.status)
//                   .offset(y: -47)
                   .padding(.top, -95)
                   .shadow(radius: 5)
                
                HStack {
                   Text("Abhängedatum:")
                      .foregroundStyle(.black.opacity(0.75))
                      .fontWeight(.semibold)
                      .padding(.trailing, -2)
                   
                   Text("\(DateTimeFormatter.formatDate(position.expiresAt))")
                      .fontWeight(.semibold)
                      .foregroundStyle(getDateColor(status: position.status))
                }.padding(.top, 10)
                
                VStack{
                   ProgressInfoView(status: position.status)
                      .padding(.leading) .padding(.trailing)
                      .padding(.top, 8) .padding(.bottom, 8)
                   
                   ProgressBarView(status: position.status)
                       .padding(.leading) .padding(.trailing)
                   if position.status == .notDisplayed {
                      Text("Mache jetzt ein Foto des aufgehängten Plakats und bestätige die Position")
                         .font(.system(size: 10))
                         .foregroundStyle(.secondary)
                   }
                }
                
                var mockUsers: [GetIdentityDTO] {
                   [mockIdentity1, mockIdentity2]
                }
                List{
                   Section {
//                      var mockUsers: [GetIdentityDTO] {
//                         [mockIdentity1, mockIdentity2]
//                      }
                      //                      position.responsibleUserIds
                      ForEach (mockUsers, id: \.self) { user in
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
                      Text("Verantwortliche (2)")
                   }
                }
                .scrollDisabled(true)
                .frame(height: CGFloat((mockUsers.count * 15) + (mockUsers.count < 4 ? 130 : 0)), alignment: .top)
                //             .scrollContentBackground(.hidden)
                .environment(\.defaultMinListHeaderHeight, 10)
                
                Form {
                   Section {
                      HStack {
                         Text("Am Grabstein 6,\n12345 Transilvanien \nDeutschland \n51.500603516488205, 6.545327532716446")
                         Spacer()
                         VStack {
                            Button(action: {  }) {
                               Image(systemName: "map.fill")
                            }
                            .padding(.top, 10)
                            Spacer()
                         }
                      }
                   } header: {
                      Text("Adresse in der Nähe")
                   }
                }
                .scrollDisabled(true)
                .frame(height: 180)
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
   Posters_PositionView(position: mockPosterPosition1)
}
