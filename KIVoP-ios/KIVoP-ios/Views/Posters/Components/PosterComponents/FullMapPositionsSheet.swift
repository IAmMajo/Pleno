//
//  FullMapPositionsView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 29.01.25.
//

import SwiftUI
import PosterServiceDTOs
import MapKit

struct FullMapPositionsSheet: View {
   let locationsPositions: [(location: Location, position: PosterPositionResponseDTO)]
   let poster: PosterResponseDTO
   
   @State var isShowingPosition: Bool = false
   @State var isShowingOverlay: Bool = false
   @State var selectedLocationPosition: (location: Location, position: PosterPositionResponseDTO)? = nil
   
   @Environment(\.dismiss) var dismiss
   
   func getTextColor(position: PosterPositionResponseDTO) -> (text: String, color: Color) {
      let status = position.status
      switch status {
      case .hangs:
         if position.expiresAt < Calendar.current.date(byAdding: .day, value: 1, to: Date())! {
            return (text: "hängt", color: .orange)
         } else {
            return (text: "hängt", color: .blue)
         }
      case .takenDown:
         return (text: "abgehängt", color: .green)
      case .toHang:
         return (text: "hängt noch nicht", color: .gray)
      case .overdue:
         return (text: "hängt (überfällig)", color: .red)
      case .damaged:
         return (text: "ist beschädigt oder fehlt", color: .yellow)
      }
   }
   
   var body: some View {
      NavigationStack {
      Map(){
         ForEach(locationsPositions, id: \.position.id) { item in
            Annotation(item.location.name, coordinate: item.location.coordinate) {
               VStack {
                  ZStack {
                     Circle()
                        .fill(.background)
                        .shadow(radius: 5)
                        .overlay(
                           Image("TestPosterImage")
                              .resizable()
                              .scaledToFit()
                              .clipShape(RoundedRectangle(cornerRadius: 3))
                              .frame(width: 35, height: 35)
                        )
                        .frame(width: 52, height: 52)
                        .overlay(alignment: .bottom) {
                           IndicatorShape()
                              .fill(getTextColor(position: item.position).color)
                              .frame(width: 15, height: 10)
                              .offset(y: 5)
                        }
                     Circle()
                        .stroke(getTextColor(position: item.position).color, lineWidth: 4)
                        .frame(width: 52-4, height: 52-4)
                  }
                  .onTapGesture {
                     isShowingOverlay = true
                     selectedLocationPosition = item
                  }
                  
                  Text(item.location.name)
                     .font(.caption2)
                     .bold()
                     .foregroundColor(.primary)
                     .padding(3)
                     .frame(height: 19)
                     .background(
                        RoundedRectangle(cornerRadius: 5)
                           .fill(Color(UIColor.systemBackground).opacity(0.5))
                           .shadow(radius: 3)
                           .overlay(alignment: .top) {
                              IndicatorShape()
                                 .fill(Color(UIColor.systemBackground).opacity(0.5))
                                 .frame(width: 7, height: 4)
                                 .rotationEffect(.degrees(-180))
                                 .offset(y: -4)
                           }
                     )
                     .padding(.top, 5)
               }
               .offset(y: -18)
            }
            .annotationTitles(.hidden)
         }
      }
      .overlay(alignment: .bottom) {
         if isShowingOverlay {
            if let item = selectedLocationPosition {
               HStack {
                  VStack(alignment: .leading, spacing: 4) {
                     Text(item.location.name)
                        .font(.title3)
                        .fontWeight(.bold)
                     Text(getTextColor(position: item.position).text)
                        .foregroundStyle(getTextColor(position: item.position).color)
                        .fontWeight(.semibold)
                     Text("Abhängedatum: \(DateTimeFormatter.formatDate(item.position.expiresAt))")
                  }
                  
                  Spacer()
                  
                  VStack(alignment: .trailing, spacing: 5) {
//                     VStack(alignment: .trailing, spacing: 2) {
                        Button {
                           isShowingOverlay = false
                        } label: {
                           Image(systemName: "xmark")
                              .foregroundStyle(.gray)
                        }
//                     }
                     Spacer()
                     Button {
                        isShowingPosition = true
                     } label: {
                        Text("Details")
                     }
                     .buttonStyle(.borderedProminent)
                     .controlSize(.regular)
                  }
               }
               .padding()
               .background(Color(UIColor.systemBackground).opacity(0.9),
                           in: RoundedRectangle(cornerRadius: 10.0, style: .continuous))
               .fixedSize(horizontal: false, vertical: true)
               .padding()
            }
         }
      }
      .navigationDestination(isPresented: $isShowingPosition) {
         if let item = selectedLocationPosition {
            Posters_PositionView(posterId: poster.id, positionId: item.position.id)
               .navigationTitle(item.location.name)
         }
      }
      .navigationTitle("Alle Standorte")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
         ToolbarItem(placement: .navigationBarLeading) {
            Button("Schließen") {
               dismiss()
            }
         }
      }
   }
    }
}

#Preview {
//    FullMapPositionsSheet()
}
