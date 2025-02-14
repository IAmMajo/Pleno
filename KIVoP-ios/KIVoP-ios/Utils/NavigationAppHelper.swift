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
//  NavigationAppHelper.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 09.01.25.
//

import Foundation
import UIKit
import MapKit

// A helper class that provides navigation options for Apple Maps, Google Maps, and Waze
class NavigationAppHelper {
   static let shared = NavigationAppHelper() /// Shared singleton instance of `NavigationAppHelper`
   
   /// Private initializer to enforce singleton usage
   private init() {}
   
   // MARK: - Checking Installed Navigation Apps
   /// Checks if Google Maps and Waze are installed on the device
   func checkInstalledApps() -> (isGoogleMapsInstalled: Bool, isWazeInstalled: Bool) {
      var isGoogleMapsInstalled = false
      var isWazeInstalled = false
      
      if let googleMapsUrl = URL(string: "comgooglemaps://") {
         isGoogleMapsInstalled = UIApplication.shared.canOpenURL(googleMapsUrl)
      }
      if let wazeUrl = URL(string: "waze://") {
         isWazeInstalled = UIApplication.shared.canOpenURL(wazeUrl)
      }
      
      return (isGoogleMapsInstalled, isWazeInstalled)
   }
   
   // MARK: - Open Locations in Navigation Apps
   
   /// Opens a location in Apple Maps
   func openInAppleMaps(name: String?, coordinate: CLLocationCoordinate2D) {
      let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
      mapItem.name = name
      mapItem.openInMaps()
   }
   
   /// Opens a location in Google Maps if installed
   func openInGoogleMaps(name: String?, coordinate: CLLocationCoordinate2D) {
       var urlString = "comgooglemaps://?q=\(coordinate.latitude),\(coordinate.longitude)"
       if let name = name, !name.isEmpty {
           let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
           urlString += "&query=\(encodedName)"
       }
       
       if let url = URL(string: urlString) {
           UIApplication.shared.open(url)
       }
   }
   
   /// Opens a location in Waze if installed
   func openInWaze(coordinate: CLLocationCoordinate2D) {
      let urlString = "waze://?ll=\(coordinate.latitude),\(coordinate.longitude)&navigate=yes"
      if let url = URL(string: urlString) {
         UIApplication.shared.open(url)
      }
   }
}
