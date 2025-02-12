// This file is licensed under the MIT-0 License.
//
//  PieChartView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 16.11.24.
//

import SwiftUI
import Charts
import MeetingServiceDTOs


// MARK: - Color Mapping for Pie Chart Segments

/// colorMapping with default colors
//let colorMapping: [UInt8: Color] = [
//   0: .blue,
//   1: .green,
//   2: .orange,
//   3: .purple,
//   4: .red,
//   5: .teal,
//   6: .yellow,
//   7: .indigo,
//   8: .mint,
//   9: .pink,
//   10: .cyan,
//   11: .brown,
//]

/// A dictionary that maps voting option indices (`UInt8`) to specific colors
let colorMapping: [UInt8: Color] = [
   0: Color(hex: 0xf0d176),
   1: Color(hex: 0xfffb3a),
   2: Color(hex: 0x8bf024),
   3: Color(hex: 0x1db30c),
   4: Color(hex: 0x00c76d),
   5: Color(hex: 0x0ccdeb),
   6: Color(hex: 0x3d75fa),
   7: Color(hex: 0x231c3c),
   8: Color(hex: 0xac19bd),
   9: Color(hex: 0xc58cf5),
   10: Color(hex: 0xa87d52),
   11: Color(hex: 0x80150d),
]

// MARK: - PieChartView Component

/// A SwiftUI view that displays voting results as a pie chart
struct PieChartView: View {

   let optionTextMap: [UInt8: String] // A dictionary mapping voting option indices to their respective text descriptions
   let votingResults: GetVotingResultsDTO // The voting results data, which contains the vote counts

   var body: some View {
      VStack {
         if votingResults.totalCount != 0 {
            // MARK: - Pie Chart Visualization
            Chart(votingResults.results, id: \.index) { result in
               SectorMark(
                  angle: .value("Count", result.count), // Defines the segment size based on vote count
                  angularInset: 4 // Adds spacing between segments
               )
               .cornerRadius(6) // Smooths segment edges
               .foregroundStyle(colorMapping[result.index] ?? .black) // Assigns color from mapping
            }
            .scaledToFit()
         } else {
            // MARK: - Placeholder when No Votes are Cast
            Image(systemName: "chart.pie.fill")
               .resizable()
               .scaledToFit()
               .foregroundStyle(Color(UIColor.secondaryLabel).opacity(0.5))
         }
         
         // MARK: - Generating Legend Colors & Texts
         
         /// Creates an array of colors sorted by their option indices
         let colorArray = colorMapping
             .sorted(by: { $0.key < $1.key }) // Sort colors by index
             .map { $0.value } // Extract color values
         
         /// Creates an array of option text sorted by their indices
         let textArray = optionTextMap
            .sorted(by: { $0.key < $1.key }) // Sort labels by index
            .map { $0.value } // Extract text labels
         
         // MARK: - Wrapped Layout for Pie Chart Legend
         WrappedLayoutView(items: textArray, colors: colorArray)
            .padding(.top, 8)
      }
   }
}

// MARK: - Hex Color Extension
/// Extension to initialize `Color` using a hexadecimal value
extension Color {
   init(hex: Int, opacity: Double = 1) {
      self.init(
         .sRGB,
         red: Double((hex >> 16) & 0xff) / 255,
         green: Double((hex >> 08) & 0xff) / 255,
         blue: Double((hex >> 00) & 0xff) / 255,
         opacity: opacity
      )
   }
}

#Preview {
   PieChartView(optionTextMap: [
      0: "Enthaltung",
      1: "Rot",
      2: "Grün",
      3: "Blau"
   ], votingResults: mockVotingResults)
}
