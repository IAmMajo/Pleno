//
//  VotingsViewModel.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 22.01.25.
//

import Foundation
import Combine
import MapKit
import MeetingServiceDTOs
import SwiftUICore

//@MainActor
//class VotingsViewModel: ObservableObject {
//   @Published var votings: [GetVotingDTO] = []
//   @Published var groupedVotings: [(String, [VotingViewModel])] = []
//   @Published var symbols: [String: Color] = [:]
//
//    init() {
//        Task {
//            await fetchVotings()
//        }
//    }
//
//    func fetchVotings() async {
//        do {
//            let fetchedVotings = try await PosterService.shared.fetchPostersAsync()
//            self.votings = fetchedVotings
//            await fetchPosterPositions()
//        } catch {
//            print("Error fetching posters: \(error)")
//        }
//    }
//
//    private func fetchPosterPositions() async {
//        for poster in posters {
//            do {
//                let positions = try await PosterService.shared.fetchPosterPositionsAsync(for: poster.id)
//                posterPositionsMap[poster.id] = positions
//            } catch {
//                print("Error fetching positions for poster \(poster.id): \(error)")
//            }
//        }
//        filterPosters()
//    }
//   
//   func groupeVotings() {
//       let meetingsGrouped = Dictionary(grouping: votings.items, by: { $0.meeting })
//       let sortedMeetingsGrouped = meetingsGrouped.sorted { lhs, rhs in
//           guard let lhsMeeting = lhs.key, let rhsMeeting = rhs.key else { return false }
//           return lhsMeeting.start > rhsMeeting.start
//       }
//       return sortedMeetingsGrouped.map { (meeting, votingGroup) in
//           let sortedVotingGroup = votingGroup.sorted { lhs, rhs in
//               guard let lhsStartedAt = lhs.votingDTO.startedAt, let rhsStartedAt = rhs.votingDTO.startedAt else { return false }
//               return lhsStartedAt > rhsStartedAt
//           }
//           let meetingName = meeting?.status == .inSession
//               ? "Aktuelle Sitzung (\(meeting?.name ?? "Unknown Meeting"))"
//               : (meeting?.name ?? "Unknown Meeting")
//           return (meetingName, sortedVotingGroup)
//       }
//   }
//   
//   func loadStatus() async {
//      VotingService.shared.fetchVotingResults(votingId: votingDTO.id) { results in
//         DispatchQueue.main.async {
//            switch results {
//            case .success(let results):
//               if results.myVote != nil {
//                  self.symbolColor = .blue
//                  self.statusSymbol = "checkmark"
//               } else {
//                  self.symbolColor = self.votingDTO.isOpen ? .orange : .black
//                  self.statusSymbol = self.votingDTO.isOpen ? "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90" : ""
//               }
//            case .failure(_ /*let error*/):
//               //                   print("Fehler beim Abrufen der Ergebnisse: \(error.localizedDescription)")
//               if self.votingDTO.iVoted {
//                  self.symbolColor = .blue
//                  self.statusSymbol = "checkmark"
//               } else {
//                  self.symbolColor = self.votingDTO.isOpen ? .orange : .black
//                  self.statusSymbol = self.votingDTO.isOpen ? "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90" : ""
//               }
//            }
//         }
//      }
//   }
//   
//   private func filterPosters() {
//       filteredPosters = posters.compactMap { poster in
//           guard let positions = posterPositionsMap[poster.id], !positions.isEmpty else { return nil }
//           
//           // Find the position with the earliest `expiresAt`
//           guard let earliestPosition = positions.min(by: { $0.expiresAt < $1.expiresAt }) else { return nil }
//           
//           // Count the number of positions with specific statuses
//           let tohangCount = positions.filter { $0.status == "toHang" }.count
//           let expiredCount = positions.filter { $0.status == "overdue" }.count
//           
//           // Check if the poster is archived
//           let isArchived = positions.allSatisfy { position in
//               position.status == "takenDown" &&
//               position.expiresAt <= Calendar.current.date(byAdding: .day, value: -3, to: Date())!
//           }
//           
//           switch selectedTab {
//           case 0:
//               // Include only non-archived posters for the "Aktuell" tab
//               if !isArchived {
//                   return FilteredPoster(
//                       poster: poster,
//                       earliestPosition: earliestPosition,
//                       tohangCount: tohangCount,
//                       expiredCount: expiredCount
//                   )
//               }
//           case 1:
//               // Include only archived posters for the "Archiviert" tab
//               if isArchived {
//                   return FilteredPoster(
//                       poster: poster,
//                       earliestPosition: earliestPosition,
//                       tohangCount: tohangCount,
//                       expiredCount: expiredCount
//                   )
//               }
//           default:
//               break
//           }
//           return nil
//       }
//       .sorted {
//           // Custom sorting: prioritize "hangs" and "overdue", then by `expiresAt`
//           if $0.earliestPosition.status == "hangs" || $0.earliestPosition.status == "overdue" {
//               if $1.earliestPosition.status == "hangs" || $1.earliestPosition.status == "overdue" {
//                   return $0.earliestPosition.expiresAt < $1.earliestPosition.expiresAt
//               } else {
//                   return true
//               }
//           } else if $1.earliestPosition.status == "hangs" || $1.earliestPosition.status == "overdue" {
//               return false
//           } else {
//               return $0.earliestPosition.expiresAt < $1.earliestPosition.expiresAt
//           }
//       }
//   }
//}
