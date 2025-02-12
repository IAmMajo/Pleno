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

class MeetingViewModel: ObservableObject {
   @Published var meeting: GetMeetingDTO?
   @Published var isLoading = false
   @Published var errorMessage: String?
   
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
