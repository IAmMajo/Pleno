// This file is licensed under the MIT-0 License.
//
//  ShareSheet.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 31.12.24.
//

import Foundation
import MapKit
import SwiftUI

// MARK: - ShareSheet
/// A `UIViewControllerRepresentable` that wraps `UIActivityViewController`
/// This allows sharing content (text, links, etc.) from SwiftUI.
struct ShareSheet: UIViewControllerRepresentable {
   let activityItems: [Any]
   let applicationActivities: [UIActivity]? = nil
   
   /// Creates and returns a `UIActivityViewController` for sharing the provided items.
   func makeUIViewController(context: Context) -> UIActivityViewController {
      UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
   }
   
   func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - ShareView (Location Sharing)
/// A `UIViewControllerRepresentable` that allows users to share a formatted address and its coordinates.
struct ShareView: UIViewControllerRepresentable {
   let address: String
   let coordinate: CLLocationCoordinate2D
   
   /// Creates and returns a `UIActivityViewController` for sharing the location.
   func makeUIViewController(context: Context) -> UIActivityViewController {
      let locationString = "\(address)\n\(coordinate.latitude), \(coordinate.longitude)"
      let activityViewController = UIActivityViewController(activityItems: [locationString], applicationActivities: nil)
      return activityViewController
   }
   
   func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
