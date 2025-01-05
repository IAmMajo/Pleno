//
//  FullMapView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 31.12.24.
//

import SwiftUI
import MapKit

struct FullMapView: View {
   @Environment(\.dismiss) private var dismiss
   let address: String
   let name: String
   let coordinate: CLLocationCoordinate2D
   
   @State private var showMapOptions: Bool = false
   @State private var shareLocation = false
   
   var body: some View {
      
      MapView(name: self.name, coordinate: self.coordinate)
         .navigationBarBackButtonHidden(true)
         .navigationTitle(name)
         .navigationBarTitleDisplayMode(.inline)
         .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
               Button {
                  dismiss()
               } label: {
                  HStack {
                     Image(systemName: "chevron.backward")
                     Text("Zurück")
                  }
               }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
               Button {
                  showMapOptions = true
               } label: {
                  HStack {
                     Image(systemName: "square.and.arrow.up")
                  }
               }
            }
         }
         .confirmationDialog("\(address)\n\(coordinate.latitude), \(coordinate.longitude)", isPresented: $showMapOptions, titleVisibility: .visible) {
            Button("Öffnen mit Apple Maps") {
               openInAppleMaps()
            }
            Button("Öffnen mit Google Maps") {
               openInGoogleMaps()
            }
            Button("Öffnen mit Waze") {
               openInWaze()
            }
            Button("Teilen...") {
               shareLocation = true
            }
            Button("Abbrechen", role: .cancel) {}
         }
         .sheet(isPresented: $shareLocation) {
            ShareSheet(activityItems: [formattedShareText()])
               .presentationDetents([.medium, .large])
               .presentationDragIndicator(.hidden)
         }
   }
   
   private func openInAppleMaps() {
      let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
      mapItem.name = name
      mapItem.openInMaps()
   }

   private func openInGoogleMaps() {
      let urlString = "comgooglemaps://?q=\(coordinate.latitude),\(coordinate.longitude)"
      if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
         UIApplication.shared.open(url)
      } else {
         // Fallback to Google Maps in browser if the app is not installed
         if let webUrl = URL(string: "https://www.google.com/maps?q=\(coordinate.latitude),\(coordinate.longitude)") {
            UIApplication.shared.open(webUrl)
         }
      }
   }
   
   private func openInWaze() {
      let urlString = "waze://?ll=\(coordinate.latitude),\(coordinate.longitude)&navigate=yes"
      if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
         UIApplication.shared.open(url)
      } else {
         // Fallback to Waze in browser if the app is not installed
         if let webUrl = URL(string: "https://www.waze.com/ul?ll=\(coordinate.latitude),\(coordinate.longitude)&navigate=yes") {
            UIApplication.shared.open(webUrl)
         }
      }
   }

   private func formattedShareText() -> String {
      """
      \(address)
      """
   }
}

#Preview {
   NavigationView {
      FullMapView(address: "Am Grabstein 6, 50129 Cologne", name: "Am Grabstein 6", coordinate: CLLocationCoordinate2D(latitude: 51.500603516488205, longitude: 6.545327532716446))
   }
}
