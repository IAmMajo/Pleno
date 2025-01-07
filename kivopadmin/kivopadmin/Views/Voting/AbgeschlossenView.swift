//
//  AbgeschlossenView.swift
//  kivopadmin
//
//  Created by Amine Ahamri on 01.12.24.
//

import SwiftUI
import MeetingServiceDTOs


struct AbgeschlossenView: View {
    let voting: GetVotingDTO
    let votingResults: GetVotingResultsDTO?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(voting.question)
                    .font(.title2)
                    .padding()

                if let results = votingResults {
                    let optionTextMap = Dictionary(uniqueKeysWithValues: voting.options.map { ($0.index, $0.text) })

                    PieChartView(optionTextMap: optionTextMap, votingResults: results)
                        .frame(height: 200)
                        .padding()

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(results.results, id: \.index) { result in
                            HStack {
                                Text(optionTextMap[result.index] ?? "Enthaltung")
                                    .font(.headline)
                                Spacer()
                                Text("\(result.count) Stimmen") // 'total' durch 'count' ersetzt
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                } else {
                    Text("Keine Abstimmungsergebnisse verfügbar.")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
        }
        .background(Color.white)
    }
}
