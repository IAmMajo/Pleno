// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//
//  FullMapPositionsView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 29.01.25.
//

import SwiftUI
import PosterServiceDTOs
import MapKit

// A full-screen map view displaying all poster locations with interactive annotations
struct FullMapPositionsSheet: View {
   // MARK: - Properties
      
      /// A list of locations and their associated poster positions
      let locationsPositions: [(location: Location, position: PosterPositionResponseDTO)]
      /// The poster being displayed
      let poster: PosterResponseDTO
      /// The image of the poster
      let posterImage: UIImage?
      /// Controls whether the position detail view is displayed
      @State var isShowingPosition: Bool = false
      /// Controls whether the overlay with details of a selected location is shown
      @State var isShowingOverlay: Bool = false
      /// Stores the selected location and position when tapping on an annotation
      @State var selectedLocationPosition: (location: Location, position: PosterPositionResponseDTO)? = nil
      /// Environment variable to dismiss the view
      @Environment(\.dismiss) var dismiss
   
   // MARK: - Status Helper
   /// Determines the text and color representation of a position's status
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
   
   // MARK: - Body
   var body: some View {
      NavigationStack {
      Map(){
         // Loop through all locations and add annotations
         ForEach(locationsPositions, id: \.position.id) { item in
            Annotation(item.location.name, coordinate: item.location.coordinate) {
               VStack {
                  ZStack {
                     Circle()
                        .fill(.background)
                        .shadow(radius: 5)
                        .overlay(
                           Group {
                              if let uiImage = posterImage {
                                 Image(uiImage: uiImage) // The poster image displayed in the annotation
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 3))
                                    .frame(width: 35, height: 35)
                              } else {
                                 ProgressView()
                                    .frame(width: 35, height: 35)
                                    .background(.gray.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                              }
                           }
                        )
                        .frame(width: 52, height: 52)
                        .overlay(alignment: .bottom) {
                           // Indicator shape with color representing status
                           IndicatorShape()
                              .fill(getTextColor(position: item.position).color)
                              .frame(width: 15, height: 10)
                              .offset(y: 5)
                        }
                     // Status border ring with matching color
                     Circle()
                        .stroke(getTextColor(position: item.position).color, lineWidth: 4)
                        .frame(width: 52-4, height: 52-4)
                  }
                  .onTapGesture {
                     // Show the overlay when the annotation is tapped
                     isShowingOverlay = true
                     selectedLocationPosition = item
                  }
                  
                  // Location name label under the annotation
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
               .offset(y: -18) // Adjusts the vertical position of annotations, to make the IndicatorShape point to the location
            }
            .annotationTitles(.hidden)
         }
      }
         // MARK: - Overlay for Selected Location Details
      .overlay(alignment: .bottom) {
         if isShowingOverlay {
            if let item = selectedLocationPosition {
               HStack {
                  // location and position information
                  VStack(alignment: .leading, spacing: 4) {
                     // name of location
                     Text(item.location.name)
                        .font(.title3)
                        .fontWeight(.bold)
                     // status of position with matching color
                     Text(getTextColor(position: item.position).text)
                        .foregroundStyle(getTextColor(position: item.position).color)
                        .fontWeight(.semibold)
                     // positions expiresAt date
                     Text("Abhängedatum: \(DateTimeFormatter.formatDate(item.position.expiresAt))")
                  }
                  
                  Spacer()
                  
                  // close and navigate to position details options
                  VStack(alignment: .trailing, spacing: 5) {
                     // button to close the overlay
                     Button {
                        isShowingOverlay = false
                     } label: {
                        Image(systemName: "xmark")
                           .foregroundStyle(.gray)
                     }
                     Spacer()
                     // button to navigate to details view of position
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
      // MARK: - Navigation to Position Details View
      .navigationDestination(isPresented: $isShowingPosition) {
         if let item = selectedLocationPosition {
            Posters_PositionView(posterId: poster.id, positionId: item.position.id)
               .navigationTitle(item.location.name)
         }
      }
      // MARK: - Navigation Bar Settings
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
}
