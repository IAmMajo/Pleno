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

//func getModifiedColor(of color: Color) -> Color {
//   let uiColor = UIColor(color)
//   var hue: CGFloat = 0
//   var saturation: CGFloat = 0
//   var brightness: CGFloat = 0
//   var alpha: CGFloat = 0
//   
//   if uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
//      return Color(hue: hue, saturation: 0.78, brightness: 0.85)
//   } else {
//      return Color.black
//   }
//}

//let colorMapping: [UInt8: Color] = [
//   0: .gray.opacity(0.8),
//   1: getModifiedColor(of: .red),
//   2: getModifiedColor(of: .green),
//   3: getModifiedColor(of: .blue),
//   4: getModifiedColor(of: .purple),
//   5: getModifiedColor(of: .pink),
//   6: getModifiedColor(of: .cyan),
//   7: getModifiedColor(of: .orange),
//   8: getModifiedColor(of: .indigo),
//   9: getModifiedColor(of: .teal),
//   10: getModifiedColor(of: .yellow),
//   11: getModifiedColor(of: .mint),
//   12: getModifiedColor(of: .brown),
//]

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

struct PieChartView: View {

   let optionTextMap: [UInt8: String]
   let votingResults: GetVotingResultsDTO

   var body: some View {
      VStack {
         if votingResults.totalCount != 0 {
            Chart(votingResults.results, id: \.index) { result in
               SectorMark(
                  angle: .value("Count", result.count),
                  //            innerRadius: .ratio(0.5),
                  angularInset: 4
               )
               .cornerRadius(6)
               .foregroundStyle(colorMapping[result.index] ?? .black)
               //         .foregroundStyle(by: .value("Option", optionTextMap[result.index] ?? ""))
            }
            .scaledToFit()
            //         .chartLegend(alignment: .center, spacing: 16)
         } else {
            Image(systemName: "chart.pie.fill")
               .resizable()
               .scaledToFit()
               .foregroundStyle(Color(UIColor.secondaryLabel).opacity(0.5))
         }
         
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
