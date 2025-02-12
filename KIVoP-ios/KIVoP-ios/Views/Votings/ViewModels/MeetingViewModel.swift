// This file is licensed under the MIT-0 License.
//
//  MeetingViewModel.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 05.01.25.
//

import Foundation
import SwiftUI
import Combine
import MeetingServiceDTOs

/// ViewModel responsible for fetching and managing meeting data.
/// Conforms to `ObservableObject` to allow SwiftUI to react to state changes
class MeetingViewModel: ObservableObject {
   // Holds the fetched meeting data
   @Published var meeting: GetMeetingDTO?
   @Published var isLoading = false
   @Published var errorMessage: String?
   
   // Fetches a meeting by its `UUID` using a completion handler-based API
   func fetchMeeting(byId meetingId: UUID) {
      isLoading = true
      errorMessage = nil
      
      VotingService.shared.fetchMeeting(byId: meetingId) { [weak self] result in
         DispatchQueue.main.async {
            self?.isLoading = false
            switch result {
            case .success(let meeting):
               self?.meeting = meeting
            case .failure(let error):
               self?.errorMessage = error.localizedDescription
            }
         }
      }
   }
}

extension MeetingViewModel {
   // Fetches a meeting by its `UUID` using `async`/`await` instead of a completion handler
    func fetchMeeting(byId id: UUID) async throws -> GetMeetingDTO {
        return try await withCheckedThrowingContinuation { continuation in
           VotingService.shared.fetchMeeting(byId: id) { result in
                switch result {
                case .success(let meeting):
                    continuation.resume(returning: meeting)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
