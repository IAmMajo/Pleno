// This file is licensed under the MIT-0 License.
//
//  MapView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 11.12.24.
//

import SwiftUI
import MapKit
import PosterServiceDTOs

// MARK: - Indicator Shape
/// A small triangular shape used as an indicator below the annotation
struct IndicatorShape: Shape {
   func path(in rect: CGRect) -> Path {
      return Path { path in
         let width = rect.width
         let height = rect.height
         
         // Move to bottom center
         path.move(to: CGPoint(x: width / 2, y: height))
         // Draw lines forming a triangle pointing downward
         path.addLine(to: CGPoint(x: 0, y: 0))
         path.addLine(to: CGPoint(x: width, y: 0))
      }
   }
}

// MARK: - MapView
/// Displays a map with a location annotation containing the poster image
struct MapView: View {
   let name: String
   let coordinate: CLLocationCoordinate2D
   let posterId: UUID
   @State private var posterImage: UIImage?
   @State private var position: MapCameraPosition
   
   // Initializes the map view with a specific name and coordinate.
   init(name: String, coordinate: CLLocationCoordinate2D, posterId: UUID) {
      self.name = name
      self.coordinate = CLLocationCoordinate2D(
         latitude: coordinate.latitude,
         longitude: coordinate.longitude
      )
      self.posterId = posterId
      // Initializes the camera position centered at the given coordinate
      self._position = State(initialValue: .region(MKCoordinateRegion(
         center: coordinate,
         span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
      )))
   }
   
   var body: some View {
      Map(position: $position){
         // MARK: - Location Annotation
         Annotation(name, coordinate: coordinate) {
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
                           .frame(width: 45, height: 45)
                     } else {
                        ProgressView()
                           .frame(width: 45, height: 45)
                           .background(.gray.opacity(0.2))
                           .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                     }
                  }
               )
               .frame(width: 65, height: 65) // Base size of the annotation
               .overlay(alignment: .bottom){ // The small indicator triangle below the annotation
                  IndicatorShape()
                     .fill(.background)
                     .frame(width: 20, height: 15)
                     .offset(y: 8)
               }
               .offset(y: -(65/2)) // Aligns the bottom of the annotation with the coordinate
         }
         .annotationTitles(.hidden)
      }
      // MARK: - Lifecycle Events
      .onAppear() {
         // Adjusts the camera position slightly when the view appears
         position = .region(MKCoordinateRegion(
            center: shiftedCoordinate(coordinate),
            span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
         ))
         // loads the image of the poster asynchronous
         if posterImage == nil {
            fetchPosterImage(for: posterId)
         }
      }
      .onChange(of: coordinate) { old, newCoordinate in
         // Update the region when the coordinate changes
         position = .region(MKCoordinateRegion(
            center: shiftedCoordinate(newCoordinate),
            span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
         ))
      }
   }
   
   // MARK: - Helper Function
   /// Shifts the latitude slightly upwards so that the annotation does not cover the target location.
   private func shiftedCoordinate(_ coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
      let offset: CLLocationDegrees = 0.0004
      return CLLocationCoordinate2D(
         latitude: coordinate.latitude - offset,
         longitude: coordinate.longitude
      )
   }
   
   /// Fetches the image for the poster and stores it inside posterImage
   func fetchPosterImage(for posterId: UUID) {
      Task {
         do {
            let imageData = try await PosterService.shared.fetchPosterImage(posterId: posterId)
            if let image = UIImage(data: imageData) {
               DispatchQueue.main.async {
                  self.posterImage = image
               }
            }
         } catch {
            print("Error loading image for poster \(posterId): \(error.localizedDescription)")
         }
      }
   }
}

#Preview {
}
