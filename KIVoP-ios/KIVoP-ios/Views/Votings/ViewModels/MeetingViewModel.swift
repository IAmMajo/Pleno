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
