//
//  PosterListView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 19.01.25.
//

import SwiftUI

struct PosterListView: View {
    @StateObject private var viewModel = PosterListViewModel()

    var body: some View {
        VStack {
            Picker("Filter", selection: $viewModel.selectedTab) {
                Text("Non-To-Hang").tag(0)
                Text("To-Hang Only").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            List(viewModel.filteredPosters, id: \.poster.id) { item in
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.poster.name)
                            .font(.headline)
                        Text("Expires At: \(item.earliestExpiresAt.formatted(date: .numeric, time: .shortened))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .onAppear {
           Task {
              await viewModel.fetchPosters()
           }
        }
    }
}

#Preview {
    PosterListView()
}
