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
    let locations: [Location]
    @State private var position: MapCameraPosition

    init(locations: [Location]) {
        var shiftedLocations: [Location] = []
        for location in locations {
            shiftedLocations.append(Location(name: location.name, coordinate: CLLocationCoordinate2D(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )))
        }
        self.locations = shiftedLocations
        
        // Temporary placeholder for `@State` initialization
        _position = State(initialValue: .automatic)
    }

    var body: some View {
        Map(position: $position) {
            ForEach(locations) { location in
                Annotation(location.name, coordinate: location.coordinate) {
                   VStack {
                      // Title above the annotation
//                      Text(location.name)
//                         .font(.caption2)
//                         .bold()
//                         .foregroundColor(.primary)
//                         .padding(3)
//                         .background(
//                           RoundedRectangle(cornerRadius: 5)
//                              .fill(Color(UIColor.systemBackground).opacity(0.5))
//                              .shadow(radius: 3)
//                         )
//                         .offset(y: 5)
                      
                      Circle()
                         .fill(.background)
                         .shadow(radius: 5)
                         .overlay(
                           Image("TestPosterImage")
                              .resizable()
                              .scaledToFit()
                              .clipShape(RoundedRectangle(cornerRadius: 3))
                              .frame(width: 38, height: 38)
                         )
                         .frame(width: 55, height: 55)
                         .overlay(alignment: .bottom) {
                            IndicatorShape()
                               .fill(.background)
                               .frame(width: 15, height: 10)
                               .offset(y: 5)
                         }
                      
                      Text(location.name)
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
                   .offset(y: -20)
                }
                .annotationTitles(.hidden)
            }
        }
        .onAppear {
            // Set the position dynamically on appear
            let allCoordinates = locations.map { $0.coordinate }
            let region = calculateRegion(for: allCoordinates)
            position = .region(region)
        }
    }

    private func calculateRegion(for coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        let lats = coordinates.map { $0.latitude }
        let lons = coordinates.map { $0.longitude }
        let minLat = lats.min() ?? 0
        let maxLat = lats.max() ?? 0
        let minLon = lons.min() ?? 0
        let maxLon = lons.max() ?? 0

        let center = CLLocationCoordinate2D(
         latitude: (minLat + maxLat) / 2 + 0.002,
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
   
   MapPositionsView(locations: locations)
}
