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
