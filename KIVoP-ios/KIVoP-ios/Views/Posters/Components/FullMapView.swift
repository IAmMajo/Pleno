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
   
   @State private var isGoogleMapsInstalled = false
   @State private var isWazeInstalled = false
   
   @State private var showMapOptions: Bool = false
   @State private var shareLocation = false
   
   var body: some View {
      
      MapView(name: self.name, coordinate: self.coordinate)
         .onAppear {
            let installedApps = NavigationAppHelper.shared.checkInstalledApps()
            isGoogleMapsInstalled = installedApps.isGoogleMapsInstalled
            isWazeInstalled = installedApps.isWazeInstalled
         }
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
               NavigationAppHelper.shared.openInAppleMaps(
                  name: name,
                  coordinate: coordinate
               )
            }
            if isGoogleMapsInstalled {
               Button("Öffnen mit Google Maps") {
                  NavigationAppHelper.shared.openInGoogleMaps(name: name, coordinate: coordinate)
               }
            }
            if isWazeInstalled {
               Button("Öffnen mit Waze") {
                  NavigationAppHelper.shared.openInWaze(coordinate: coordinate)
               }
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
