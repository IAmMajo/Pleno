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
