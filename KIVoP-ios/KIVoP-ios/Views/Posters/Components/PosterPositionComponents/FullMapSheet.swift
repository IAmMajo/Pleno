// This file is licensed under the MIT-0 License.
//
//  FullMapView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 31.12.24.
//

import SwiftUI
import MapKit

// displays a full-screen map (with a poster position on it) with sharing and navigation options
struct FullMapSheet: View {
   @Environment(\.dismiss) private var dismiss
   let posterId: UUID
   let address: String
   let name: String
   let coordinate: CLLocationCoordinate2D
   
   @State private var isGoogleMapsInstalled = false
   @State private var isWazeInstalled = false
   
   @State private var showMapOptions: Bool = false
   @State private var shareLocation = false
   
   var body: some View {
      NavigationStack {
         // Displays the map with the given coordinates (of the poster position)
         MapView(name: self.name, coordinate: self.coordinate, posterId: posterId)
            .onAppear {
               // Check which navigation apps are installed on the device
               let installedApps = NavigationAppHelper.shared.checkInstalledApps()
               isGoogleMapsInstalled = installedApps.isGoogleMapsInstalled
               isWazeInstalled = installedApps.isWazeInstalled
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle(name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
               // Close button (left side of the toolbar)
               ToolbarItem(placement: .navigationBarLeading) {
                  Button("Schließen") {
                     dismiss()
                  }
               }
               // Share options button (right side of the toolbar)
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
         // MARK: - Confirmation Dialog (Map Options)
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
         // MARK: - Share Sheet
            .sheet(isPresented: $shareLocation) {
               ShareSheet(activityItems: [formattedShareText()])
                  .presentationDetents([.medium, .large]) // Allows resizing the share sheet
                  .presentationDragIndicator(.hidden) // Hides the drag indicator
            }
      }
   }
   
   // MARK: - Helper Function
   /// Formats the text to be shared when the share sheet is opened
   private func formattedShareText() -> String {
      """
      \(address)
      """
   }
}

#Preview {
}
