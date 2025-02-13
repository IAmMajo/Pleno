// This file is licensed under the MIT-0 License.
//
//  PieChartView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 13.11.24.
//

import Foundation

/// A utility struct that provides functions for formatting dates and times
struct DateTimeFormatter {
   
   // Formats a `Date` object into a human-readable string with the format `"dd.MM.yyyy"`
   static func formatDate(_ date: Date) -> String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "dd.MM.yyyy"
      return dateFormatter.string(from: date)
   }
   
   // Formats a `Date` object into a human-readable string with the format `"HH:mm"`
   static func formatTime(_ date: Date) -> String {
      let timeFormatter = DateFormatter()
      timeFormatter.dateFormat = "HH:mm"
      return timeFormatter.string(from: date)
   }
}
