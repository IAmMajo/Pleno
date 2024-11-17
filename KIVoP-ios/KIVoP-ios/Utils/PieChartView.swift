//
//  PieChartView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 16.11.24.
//

import SwiftUI
import Charts

private var options1: [Voting_option] = [
   Voting_option(index: 0, text: "Enthaltung", count: 10),
   Voting_option(index: 1, text: "Rot", count: 10),
   Voting_option(index: 2, text: "Grün", count: 30),
   Voting_option(index: 3, text: "Blau", count: 50),
   Voting_option(index: 4, text: "4", count: 10),
   Voting_option(index: 5, text: "5", count: 30),
   Voting_option(index: 6, text: "6", count: 50),
   Voting_option(index: 7, text: "7", count: 10),
   Voting_option(index: 8, text: "8", count: 30),
   Voting_option(index: 9, text: "9", count: 50),
   Voting_option(index: 10, text: "10", count: 30),
   Voting_option(index: 11, text: "11", count: 50),
]

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
   let options: [Voting_option]
   
   var body: some View {
      Chart(options, id: \.index) { option in
         SectorMark(
            angle: .value("Count", option.count!),
//            innerRadius: .ratio(0.5),
            angularInset: 4
         )
         .cornerRadius(6)
//         .foregroundStyle(colorMapping[option.index] ?? .black)
         .foregroundStyle(by: .value("Option", option.text))
      }
      .scaledToFit()
      // Später eigene Legende bauen, um mehr als 7 Farben zu haben? Optionen Limit?
      .chartLegend(alignment: .center, spacing: 16)
   }
}

#Preview {
   PieChartView(options: [
      Voting_option(index: 0, text: "Enthaltung", count: 10),
      Voting_option(index: 1, text: "Rot", count: 10),
      Voting_option(index: 2, text: "Grün", count: 30),
      Voting_option(index: 3, text: "Blau", count: 50),
    ])
}
