// This file is licensed under the MIT-0 License.
//
//  PollPieChartView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 18.01.25.
//

import SwiftUI
import Charts
import PollServiceDTOs

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

struct PollPieChartView: View {
   let optionTextMap: [UInt8: String]
   let pollResults: GetPollResultsDTO

   var body: some View {
      VStack {
         if pollResults.totalCount != 0 {
            Chart(pollResults.results, id: \.index) { result in
               SectorMark(
                  angle: .value("Count", result.count),
                  //            innerRadius: .ratio(0.5),
                  angularInset: 4
               )
               .cornerRadius(6)
               .foregroundStyle(colorMappingPoll[result.index] ?? .black)
   //                     .foregroundStyle(by: .value("Option", optionTextMap[result.index] ?? ""))
            }
            .scaledToFit()
   //         .chartLegend(alignment: .center, spacing: 16)
         } else {
            Image(systemName: "chart.pie.fill")
               .resizable()
               .scaledToFit()
               .foregroundStyle(Color(UIColor.secondaryLabel).opacity(0.5))
         }
         
         let colorArray = colorMappingPoll
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
      0: "",
      1: "Weizenbrötchen",
      2: "Vollkornbrötchen",
      3: "Milchbrötchen",
   ], pollResults: mockPollResults)
}
