//
//  PosterDetailViewModel.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 20.01.25.
//

import Foundation
import Combine
import PosterServiceDTOs

@MainActor
class PosterDetailViewModel: ObservableObject {
    @Published var poster: PosterResponseDTO?
    @Published var positions: [PosterPositionResponseDTO] = []
    @Published var isLoading = false
    @Published var error: String?

    private let posterId: UUID

    init(posterId: UUID) {
        self.posterId = posterId
    }

    func fetchPoster() async {
        isLoading = true
        error = nil
        do {
            // Fetch the poster details
            poster = try await PosterService.shared.fetchPosterAsync(byId: posterId)
            // Fetch the positions for the poster
            positions = try await PosterService.shared.fetchPosterPositionsAsync(for: posterId)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
