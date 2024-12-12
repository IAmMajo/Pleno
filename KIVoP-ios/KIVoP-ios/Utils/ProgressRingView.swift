//
//  RingChartView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 11.12.24.
//

import SwiftUI
import Charts

struct PosterCount {
  var index: Int
  var count: Int
}

let byIndex: [PosterCount] = [
   .init(index: 0, count: 3),
   .init(index: 1, count: 2),
]

let colorMapRing: [Int: Color] = [
   0: .blue,
   1: .gray
]

struct ProgressRingView: View {
   let data: [PosterCount]
   let status: Status
   
   var colorMapRing: [Int: Color] {
      return [
      0: status == .hung ? .blue : .green,
      1: .gray
      ]
   }
   
   var body: some View {
      Chart(data, id: \.index) { item in
         SectorMark(
            angle: .value("Count", item.count),
            innerRadius: .ratio(0.75),
            angularInset: 4
         )
         .cornerRadius(6)
         .foregroundStyle(colorMapRing[item.index] ?? .black)
      }
      .scaledToFit()
   }
}

#Preview {
   ProgressRingView(data: byIndex, status: Status.takenDown)
}

