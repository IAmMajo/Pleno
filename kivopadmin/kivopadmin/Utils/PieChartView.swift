//
//  PieChartView.swift
//  KIVoP-ios
//
//  PieChart für Abstimmungen
//

import SwiftUI
import Charts
import MeetingServiceDTOs


let colorMapping: [UInt8: Color] = [
    0: Color(rgba: 0xf0d176),
    1: Color(rgba: 0xfffb3a),
    2: Color(rgba: 0x8bf024),
    3: Color(rgba: 0x1db30c),
    4: Color(rgba: 0x00c76d),
    5: Color(rgba: 0x0ccdeb),
    6: Color(rgba: 0x3d75fa),
    7: Color(rgba: 0x231c3c),
    8: Color(rgba: 0xac19bd),
    9: Color(rgba: 0xc58cf5),
    10: Color(rgba: 0xa87d52),
    11: Color(rgba: 0x80150d),
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
         .foregroundStyle(colorMapping[result.index] ?? .gray)
        // .foregroundStyle(by: .value("Option", optionTextMap[result.index] ?? "Enthaltung"))
      }
      .scaledToFit()
      // Später eigene Legende bauen, um mehr als 7 Farben zu haben? Optionen Limit?
      .chartLegend(alignment: .center, spacing: 16)
   }
}
