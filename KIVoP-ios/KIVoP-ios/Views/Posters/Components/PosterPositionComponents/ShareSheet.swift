//
//  ShareSheet.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 31.12.24.
//

import Foundation
import MapKit
import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
   let activityItems: [Any]
   let applicationActivities: [UIActivity]? = nil
   
   func makeUIViewController(context: Context) -> UIActivityViewController {
      UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
   }
   
   func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ShareView: UIViewControllerRepresentable {
   let address: String
   let coordinate: CLLocationCoordinate2D
   
   func makeUIViewController(context: Context) -> UIActivityViewController {
      let locationString = "\(address)\n\(coordinate.latitude), \(coordinate.longitude)"
      let activityViewController = UIActivityViewController(activityItems: [locationString], applicationActivities: nil)
      return activityViewController
   }
   
   func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
