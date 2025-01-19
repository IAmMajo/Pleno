//
//  PollPieChartView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 18.01.25.
//

import SwiftUI
import Charts

struct PollPieChartView: View {
   let optionTextMap: [UInt8: String]
   let pollResults: PollResults

   var body: some View {
      VStack {
         Chart(pollResults.results, id: \.index) { result in
            SectorMark(
               angle: .value("Count", result.count),
               //            innerRadius: .ratio(0.5),
               angularInset: 4
            )
            .cornerRadius(6)
            .foregroundStyle(colorMapping[result.index] ?? .black)
//                     .foregroundStyle(by: .value("Option", optionTextMap[result.index] ?? ""))
         }
         .scaledToFit()
//         .chartLegend(alignment: .center, spacing: 16)
         
         let colorArray = colorMapping
             .sorted(by: { $0.key < $1.key }) // Sort by key
             .map { $0.value } // Extract values
         
         let textArray = optionTextMap
            .sorted(by: { $0.key < $1.key })
            .map { $0.value }
         
         WrappedLayoutView(items: textArray, colors: colorArray)
            .padding(.top, 8)
      }
   }
}

#Preview {
   PollPieChartView(optionTextMap: [
      0: "Enthaltung",
      1: "Weizenbrötchen",
      2: "Vollkornbrötchen",
      3: "Milchbrötchen",
   ], pollResults: mockPollResults)
}
