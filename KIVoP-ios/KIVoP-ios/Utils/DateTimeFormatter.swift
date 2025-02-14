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
