//
//  MapPositionsView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 09.01.25.
//

import SwiftUI
import MapKit
import PosterServiceDTOs

struct Location: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}

struct MapPositionsView: View {
    let locationsPositions: [(location: Location, position: PosterPositionResponseDTO)]
//    let locations: [Location]
    @State private var position: MapCameraPosition

    init(locationsPositions: [(location: Location, position: PosterPositionResponseDTO)]) {
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
        
//        // Temporary placeholder for `@State` initialization
//        _position = State(initialValue: .automatic)
       
       if let initialRegion = locationsPositions.isEmpty
            ? nil
            : MapPositionsView.calculateRegion(for: locationsPositions.map { $0.location.coordinate }) {
          _position = State(initialValue: .region(initialRegion))
       } else {
          _position = State(initialValue: .automatic)
       }
    }
   
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

    var body: some View {
        Map(position: $position) {
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
                                  .fill(getColor(position: item.position))
                                  .frame(width: 15, height: 10)
                                  .offset(y: 5)
                            }
                         Circle()
                            .stroke(getColor(position: item.position), lineWidth: 4)
                            .frame(width: 52-4, height: 52-4)
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
        .onAppear {
//            // Set the position dynamically on appear
           if !locationsPositions.isEmpty {
              let allCoordinates = locationsPositions.map { $0.location.coordinate }
              let region = MapPositionsView.calculateRegion(for: allCoordinates)
              position = .region(region)
           }
        }
    }

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
//         latitudeDelta: max(maxLat - minLat, 0.01) * 1.4,
//         longitudeDelta: max(maxLon - minLon, 0.01) * 1.4
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
   
//   MapPositionsView(locations: locations)
}
