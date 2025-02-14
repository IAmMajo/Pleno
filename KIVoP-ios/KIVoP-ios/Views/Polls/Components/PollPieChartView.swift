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
//  PollPieChartView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 18.01.25.
//

import SwiftUI
import Charts
import PollServiceDTOs

// MARK: - Color Mapping for Pie Chart Segments
/// A dictionary that maps voting option indices (`UInt8`) to specific colors
let colorMappingPoll: [UInt8: Color] = [
   0: Color(.clear),
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

/// A SwiftUI view that displays poll results as a pie chart
struct PollPieChartView: View {
   let optionTextMap: [UInt8: String] // A dictionary mapping poll option indices to their respective text descriptions
   let pollResults: GetPollResultsDTO // The poll results data, which contains the vote counts

   var body: some View {
      VStack {
         if pollResults.totalCount != 0 {
            // MARK: - Pie Chart Visualization
            Chart(pollResults.results, id: \.index) { result in
               SectorMark(
                  angle: .value("Count", result.count), // Defines the segment size based on vote count
                  angularInset: 4 // Adds spacing between segments
               )
               .cornerRadius(6) // Smooths segment edges
               .foregroundStyle(colorMappingPoll[result.index] ?? .black) // Assigns color from mapping
            }
            .scaledToFit()
   //         .chartLegend(alignment: .center, spacing: 16)
         } else {
            // MARK: - Placeholder when No Votes are Cast
            Image(systemName: "chart.pie.fill")
               .resizable()
               .scaledToFit()
               .foregroundStyle(Color(UIColor.secondaryLabel).opacity(0.5))
         }
         
         // MARK: - Generating Legend Colors & Texts
         
         /// Creates an array of colors sorted by their option indices
         let colorArray = colorMappingPoll
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

#Preview {
   PollPieChartView(optionTextMap: [
      0: "",
      1: "Weizenbrötchen",
      2: "Vollkornbrötchen",
      3: "Milchbrötchen",
   ], pollResults: mockPollResults)
}
