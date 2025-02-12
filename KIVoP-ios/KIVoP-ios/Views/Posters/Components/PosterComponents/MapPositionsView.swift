// This file is licensed under the MIT-0 License.
//
//  MapPositionsView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 09.01.25.
//

import SwiftUI
import MapKit
import PosterServiceDTOs

// represents a location with a unique ID, name, and geographical coordinates
struct Location: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}

// A SwiftUI view that displays multiple poster positions on a map
struct MapPositionsView: View {
   // The poster image to be displayed in map annotations
   let posterImage: UIImage?
   // A list of tuples containing a `Location` and its associated `PosterPositionResponseDTO`
    let locationsPositions: [(location: Location, position: PosterPositionResponseDTO)]
   // Controls the camera position of the map
    @State private var position: MapCameraPosition

   // MARK: - Initializer
   // Initializes the map with locations and a poster image
   init(posterImage: UIImage?, locationsPositions: [(location: Location, position: PosterPositionResponseDTO)]) {
      self.posterImage = posterImage
      
      // Creates a shifted copy of the locationsPositions to avoid modifying the original data
      var shiftedLocationsPositions: [(location: Location, position: PosterPositionResponseDTO)] = []
      for item in locationsPositions {
         shiftedLocationsPositions.append((
            location: Location(name: item.location.name, coordinate: CLLocationCoordinate2D(
               latitude: item.location.coordinate.latitude,
               longitude: item.location.coordinate.longitude)),
            position: item.position
         ))
      }
      self.locationsPositions = shiftedLocationsPositions

      // Sets an appropriate initial camera position based on available locations
       if let initialRegion = locationsPositions.isEmpty
            ? nil
            : MapPositionsView.calculateRegion(for: locationsPositions.map { $0.location.coordinate }) {
          _position = State(initialValue: .region(initialRegion))
       } else {
          _position = State(initialValue: .automatic)
       }
    }
   
   // MARK: - Get Annotation Color
   /// Determines the color of the annotation indicator based on the position's status
   func getColor(position: PosterPositionResponseDTO) -> Color {
      let status = position.status
      switch status {
      case .hangs:
         if position.expiresAt < Calendar.current.date(byAdding: .day, value: 1, to: Date())! {
            return .orange
         } else {
            return .blue
         }
      case .takenDown:
         return .green
      case .toHang:
         return .gray
      case .overdue:
         return .red
      case .damaged:
         return .yellow
      }
   }

   // MARK: - View Body
    var body: some View {
        Map(position: $position) {
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
                                 // display poster image inside the annotation
                                 if let uiImage = posterImage {
                                    Image(uiImage: uiImage)
                                       .resizable()
                                       .scaledToFit()
                                       .clipShape(RoundedRectangle(cornerRadius: 3))
                                       .frame(width: 35, height: 35)
                                 } else {
                                    // Display a loading indicator if the image is not available
                                    ProgressView()
                                       .frame(width: 35, height: 35)
                                       .background(.gray.opacity(0.2))
                                       .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                                 }
                              }
                            )
                            .frame(width: 52, height: 52) // Adjust outer circle size
                            .overlay(alignment: .bottom) {
                               // Bottom indicator shape colored based on poster status
                               IndicatorShape()
                                  .fill(getColor(position: item.position))
                                  .frame(width: 15, height: 10)
                                  .offset(y: 5)
                            }
                         
                         // Outer stroke ring with color based on poster status
                         Circle()
                            .stroke(getColor(position: item.position), lineWidth: 4)
                            .frame(width: 52-4, height: 52-4)
                      }
                      
                      // Display the location name under the annotation
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
        .onAppear {
           // Dynamically adjust the map region when the view appears
           if !locationsPositions.isEmpty {
              let allCoordinates = locationsPositions.map { $0.location.coordinate }
              let region = MapPositionsView.calculateRegion(for: allCoordinates)
              position = .region(region)
           }
        }
    }

   // MARK: - Calculate Map Region
   /// Computes a suitable map region that includes all given coordinates
    static func calculateRegion(for coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        let lats = coordinates.map { $0.latitude }
        let lons = coordinates.map { $0.longitude }
        let minLat = lats.min() ?? 0
        let maxLat = lats.max() ?? 0
        let minLon = lons.min() ?? 0
        let maxLon = lons.max() ?? 0

        let center = CLLocationCoordinate2D(
         latitude: (minLat + maxLat) / 2 /*+ 0.002*/,
         longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.4,
            longitudeDelta: (maxLon - minLon) * 1.4
        )
        return MKCoordinateRegion(center: center, span: span)
    }
}


#Preview {
   let locations: [Location] = [
      Location(name: "Am Grabstein 6", coordinate: CLLocationCoordinate2D(latitude: 51.500603516488205, longitude: 6.545327532716446)),
      Location(name: "Hinter der Obergasse 27", coordinate: CLLocationCoordinate2D(latitude: 51.504906516488205, longitude: 6.525927532716446)),
      Location(name: "Baumhaus 5", coordinate: CLLocationCoordinate2D(latitude: 51.494653516488205, longitude: 6.525307532716446)),
      Location(name: "Katerstraße 3", coordinate: CLLocationCoordinate2D(latitude: 51.495553516488205, longitude: 6.565227532716446))
   ]
}
