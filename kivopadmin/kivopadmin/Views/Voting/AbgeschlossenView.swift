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
                    PieChartView(optionTextMap: Dictionary(uniqueKeysWithValues: voting.options.map { ($0.index, $0.text) }),
                                 votingResults: results)
                        .frame(height: 200)
                        .padding()

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(results.results, id: \.index) { result in
                            HStack {
                                Text(voting.options.first { $0.index == result.index }?.text ?? "Enthaltung")
                                    .font(.headline)
                                Spacer()
                                Text("\(result.total) Stimmen")
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
