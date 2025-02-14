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
