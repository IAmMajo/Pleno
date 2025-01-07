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

let colorMapping: [UInt8: Color] = [
   0: .blue,
   1: .green,
   2: .orange,
   3: .purple,
   4: .red,
   5: .teal,
   6: .yellow,
   7: .indigo,
   8: .mint,
   9: .pink,
   10: .cyan,
   11: .brown,
]

struct PieChartView: View {

   let optionTextMap: [UInt8: String]
   let votingResults: GetVotingResultsDTO

   var body: some View {
      Chart(votingResults.results, id: \.index) { result in
         SectorMark(
            angle: .value("Count", result.count),
//            innerRadius: .ratio(0.5),
            angularInset: 4
         )
         .cornerRadius(6)
//         .foregroundStyle(colorMapping[option.index] ?? .black)
         .foregroundStyle(by: .value("Option", optionTextMap[result.index] ?? "Enthaltung"))
      }
      .scaledToFit()
      // Später eigene Legende bauen, um mehr als 7 Farben zu haben? Optionen Limit?
      .chartLegend(alignment: .center, spacing: 16)
   }
}
