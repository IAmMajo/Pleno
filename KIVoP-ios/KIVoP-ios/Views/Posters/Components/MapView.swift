//
//  MapView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 11.12.24.
//

import SwiftUI
import MapKit
import PosterServiceDTOs

struct IndicatorShape: Shape {
   
   func path(in rect: CGRect) -> Path {
      return Path { path in
         let width = rect.width
         let height = rect.height
         
         path.move(to: CGPoint(x: width / 2, y: height))
         path.addLine(to: CGPoint(x: 0, y: 0))
         path.addLine(to: CGPoint(x: width, y: 0))
      }
   }
}

struct MapView: View {
   let name: String
   let coordinate: CLLocationCoordinate2D
   @State private var position: MapCameraPosition
   
   init(name: String, coordinate: CLLocationCoordinate2D) {
      self.name = name
      self.coordinate = coordinate
      self._position = State(initialValue: .region(MKCoordinateRegion(
         center: coordinate,
         span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
      )))
   }
   
   var body: some View {
      Map(position: $position){
         Annotation(name, coordinate: coordinate) {
            Circle()
               .fill(.background)
               .shadow(radius: 5)
               .overlay(
                  Image("TestPosterImage")
                     .resizable()
                     .scaledToFit()
                     .clipShape(RoundedRectangle(cornerRadius: 3))
                     .frame(width: 40, height: 40)
               )
               .frame(width: 65, height: 65)
               .overlay(alignment: .bottom){
                  IndicatorShape()
                     .fill(.background)
                     .frame(width: 20, height: 15)
                     .offset(y: 8)
               }
         }
         .annotationTitles(.hidden)
      }
      .onAppear() {
         position = .region(MKCoordinateRegion(
            center: shiftedCoordinate(coordinate),
            span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
         ))
      }
      .onChange(of: coordinate) { old, newCoordinate in
         // Update the region when the coordinate changes
         position = .region(MKCoordinateRegion(
            center: shiftedCoordinate(newCoordinate),
            span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
         ))
      }
   }
   
   private func shiftedCoordinate(_ coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
      // shifts the latitude upwards to move the annotation to the top
      let offset: CLLocationDegrees = 0.001
      return CLLocationCoordinate2D(
         latitude: coordinate.latitude - offset,
         longitude: coordinate.longitude
      )
   }
}

#Preview {
   MapView(name: "Am Grabstein 6", coordinate: CLLocationCoordinate2D(latitude: 51.500603516488205, longitude: 6.545327532716446))
}
