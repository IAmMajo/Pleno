//
//  PieChartView 2.swift
//  kivopadmin
//
//  Created by Amine Ahamri on 19.01.25.
//


import SwiftUI
import Charts
import PollServiceDTOs

struct PieChartView_Polls: View {
    let optionTextMap: [Int: String]
    let votingResults: GetPollResultsDTO

    var body: some View {
        Chart(votingResults.results, id: \.index) { result in
            SectorMark(
                angle: .value("Count", result.count),
                angularInset: 4
            )
            .cornerRadius(6)
            .foregroundStyle(colorMapping[result.index] ?? .gray)
        }
        .scaledToFit()
        .chartLegend(alignment: .center, spacing: 16)
    }
}
