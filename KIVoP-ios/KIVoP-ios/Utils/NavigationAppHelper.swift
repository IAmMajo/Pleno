// This file is licensed under the MIT-0 License.
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
