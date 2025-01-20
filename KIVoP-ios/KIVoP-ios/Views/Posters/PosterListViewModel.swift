//
//  PosterListViewModel.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 19.01.25.
//

import Foundation
import SwiftUI
import Combine
import PosterServiceDTOs

@MainActor
class PosterListViewModel: ObservableObject {
    @Published var posters: [PosterResponseDTO] = []
    @Published var filteredPosters: [(poster: PosterResponseDTO, earliestExpiresAt: Date)] = []
    @Published var selectedTab: Int = 0 {
        didSet {
            filterPosters()
        }
    }

    private var posterPositionsMap: [UUID: [PosterPositionResponseDTO]] = [:]

    init() {
        Task {
            await fetchPosters()
        }
    }

    func fetchPosters() async {
        do {
            let fetchedPosters = try await PosterService.shared.fetchPostersAsync()
            self.posters = fetchedPosters
            await fetchPosterPositions()
        } catch {
            print("Error fetching posters: \(error)")
        }
    }

    private func fetchPosterPositions() async {
        for poster in posters {
            do {
                let positions = try await PosterService.shared.fetchPosterPositionsAsync(for: poster.id)
                posterPositionsMap[poster.id] = positions
            } catch {
                print("Error fetching positions for poster \(poster.id): \(error)")
            }
        }
        filterPosters()
    }

    private func filterPosters() {
        filteredPosters = posters.compactMap { poster in
            guard let positions = posterPositionsMap[poster.id], !positions.isEmpty else { return nil }
            let earliestExpiresAt = positions.min(by: { $0.expiresAt < $1.expiresAt })?.expiresAt

            switch selectedTab {
            case 0:
                if positions.contains(where: { $0.status != "tohang" }) {
                    return (poster, earliestExpiresAt ?? Date.distantFuture)
                }
            case 1:
                if !positions.contains(where: { $0.status != "tohang" }) {
                    return (poster, earliestExpiresAt ?? Date.distantFuture)
                }
            default:
                return nil
            }
            return nil
        }
    }
}
