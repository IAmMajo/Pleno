//
//  PostersViewModel.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 09.12.24.
//

import Foundation
import SwiftUI
import Combine
import PosterServiceDTOs
import MeetingServiceDTOs

@MainActor
class PostersViewModel: ObservableObject {
    @Published var posters: [PosterResponseDTO] = []
//   @Published var filteredPosters: [(poster: PosterResponseDTO, earliestPositionDate: Date/*, tohangCount: Int, expiredCount: Int*/)] = []
   @Published var filteredPosters: [(poster: PosterResponseDTO, earliestPosition: PosterPositionResponseDTO, tohangCount: Int, expiredCount: Int)] = []
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
           
           // Find the position with the earliest `expiresAt`
           guard let earliestPosition = positions.min(by: { $0.expiresAt < $1.expiresAt }) else { return nil }
           
           // Additional fields
//           let earliestPositionStatus = earliestPosition.status
           let tohangCount = positions.filter { $0.status == "toHang" }.count
           let expiredCount = positions.filter { $0.status == "overdue" }.count
           
           switch selectedTab {
           case 0:
               if positions.contains(where: { $0.status != "archived" }) { // archived (platzhalter) wegmachen, anders kalkulieren
                   return (poster, earliestPosition, tohangCount, expiredCount)
               }
           case 1:
               if !positions.contains(where: { $0.status != "archived" }) { // archived (platzhalter) wegmachen, anders
                   return (poster, earliestPosition, tohangCount, expiredCount)
               }
           default:
               break
           }
          return nil
       }
   }
   
//   private func filterPosters() {
//       filteredPosters = posters.compactMap { poster in
//           guard let positions = posterPositionsMap[poster.id], !positions.isEmpty else { return nil }
//           
//           // Find the position with the earliest expiresAt
//          let earliestPositionDate = positions.min(by: { $0.expiresAt < $1.expiresAt })?.expiresAt
////          let earliestPositionStatus = positions.min(by: { $0.expiresAt < $1.expiresAt })?.status
////          let tohangCount = positions.filter { $0.status == "tohang" }.count
////          let expiredCount = positions.filter { $0.status == "expired" }.count
//           
//           switch selectedTab {
//           case 0:
//               if positions.contains(where: { $0.status != "archived" }) {
//                   if let earliestPositionDate = earliestPositionDate {
//                      return (poster, earliestPositionDate/*, tohangCount, expiredCount*/)
//                   }
//               }
//           case 1:
//               if !positions.contains(where: { $0.status != "archived" }) {
//                   if let earliestPositionDate = earliestPositionDate {
//                      return (poster, earliestPositionDate/*, tohangCount, expiredCount*/)
//                   }
//               }
//           default:
//               return nil
//           }
//           return nil
//       }
//   }
}

//class PostersViewModel: ObservableObject {
//   
//   @Published var searchText: String = ""
//   @Published var selectedTab: Int = 0
//   @Published var meetings: [GetMeetingDTO] = []
//   @Published var posters: [PosterResponseDTO] = []
//   @Published var posterPositions: [PosterPositionResponseDTO] = []
//   @Published var posterPositionsMap: [UUID: [PosterPositionResponseDTO]] = [:]
//   @Published var isLoading: Bool = false
//   @Published var errorMessage: String?
//   
//   private var cancellables = Set<AnyCancellable>()
//
//   
//    init() {
//       loadPosters()
////       posters = mockPosters
////       posterPositions = mockPosterPositions
//    }
//   
//   func loadPosters() {
//      isLoading = true
//      PosterService.shared.fetchPosters { [weak self] result in
//         DispatchQueue.main.async {
//            switch result {
//            case .success(let posters):
//               self?.posters = posters
//            case .failure(let error):
//               self?.errorMessage = error.localizedDescription
//               print("Fehler beim Laden der Poster: \(error)")
//            }
//         }
//      }
//      isLoading = false
//   }
//   
//   func loadPosterPositions(posterId: UUID) {
//      PosterService.shared.fetchPosterPositions(for: posterId) { [weak self] result in
//         DispatchQueue.main.async {
//            switch result {
//            case .success(let positions):
//               self?.posterPositions = positions
//            case .failure(let error):
//               self?.errorMessage = error.localizedDescription
//               print("Fehler beim Laden der PosterPositions: \(error)")
//            }
//         }
//      }
//   }
//   
//   func loadPosterPositions(posterId: UUID) async {
//      do {
//         let positions = try await PosterService.shared.fetchPosterPositionsAsync(for: posterId)
//         DispatchQueue.main.async {
//            self.posterPositionsMap[posterId] = positions
//         }
//      } catch {
//         DispatchQueue.main.async {
//            self.errorMessage = error.localizedDescription
//            print("Fehler beim Laden der PosterPositions: \(error)")
//         }
//      }
//   }
//
//   func getFirstPosterExpiresPosition(posterId: UUID) async -> PosterPositionResponseDTO? {
//      if posterPositionsMap[posterId] == nil {
//         await loadPosterPositions(posterId: posterId)
//      }
//      guard let positions = posterPositionsMap[posterId] else { return nil }
//      let positionsSorted = positions.sorted(by: { $0.expiresAt < $1.expiresAt })
//      return positionsSorted.first
//   }
//   
////   var posterExpiresDates: [UUID: Date] {
////      var dates: [UUID: Date] = [:]
////      for poster in posters {
////         let positionsSorted = getPosterPositions(poster: poster).sorted(by: { $0.expiresAt < $1.expiresAt })
////         dates[poster.id!] = positionsSorted.first?.expiresAt
////      }
////      return dates
////   }
////   
//   var posterExpiresPositions: [UUID: PosterPositionResponseDTO] {
//      var positions: [UUID: PosterPositionResponseDTO] = [:]
//      for poster in posters {
//         loadPosterPositions(posterId: poster.id)
//         let positionsSorted = posterPositions.sorted(by: { $0.expiresAt < $1.expiresAt })
//         positions[poster.id] = positionsSorted.first
//      }
//      return positions
//   }
////   
//   private func sortedPosters() -> [PosterResponseDTO] {
//      // Sort the posters by their corresponding expiration dates
////      let sortedPosters = posters.sorted { poster1, poster2 in
////         guard let date1 = posterExpiresDates[poster1.id!],
////               let date2 = posterExpiresDates[poster2.id!] else {
////            return false
////         }
////         return date1 < date2
////      }
//      
//      let sortedPosters = posters.sorted { poster1, poster2 in
//         guard let position1 = posterExpiresPositions[poster1.id],
//               let position2 = posterExpiresPositions[poster2.id] else {
//            return false
//         }
//         return position1.expiresAt < position2.expiresAt
//      }
//      
//      return sortedPosters
//   }
//
//    // Filtert Sitzungen basierend auf dem Tab
//   var filteredPosters: [PosterResponseDTO] {
//       var currentPosters: [PosterResponseDTO] = []
//       var archivedPosters: [PosterResponseDTO] = []
//      let sortedPosters = sortedPosters()
//       for poster in sortedPosters {
//          loadPosterPositions(posterId: poster.id)
//          if posterPositions.contains(where: { $0.status != "tohang" }) {
//             currentPosters.append(poster)
//          } else {
//             archivedPosters.append(poster)
//          }
//       }
//        switch selectedTab {
//        case 0:
//           return currentPosters
//        case 1:
//            return archivedPosters
//        default:
//            return []
//        }
//    }
//   
//}

public struct Poster: Identifiable, Codable, Hashable {
   public let id: UUID?
   public let posterPositionIds: [UUID]
   public let name: String
   public let description: String
   public let imageBase64: String
}

public struct PosterPosition: Identifiable, Codable, Hashable {
   public let id: UUID
   public let responsibleUserIds: [UUID]
   public var latitude: Double
   public var longitude: Double
   public var status: Status
   public var imageBase64: String // Hinzugefügt
   public var expiresAt: Date
   public var postedAt: Date
}

let mockIdentity1: GetIdentityDTO = GetIdentityDTO(id: UUID(), name: "Heinz-Peters")
let mockIdentity2: GetIdentityDTO = GetIdentityDTO(id: UUID(), name: "Franz")
let mockUser1: ResponsibleUsersDTO = ResponsibleUsersDTO(id: UUID(), name: "Heinz-Peters")
let mockUser2: ResponsibleUsersDTO = ResponsibleUsersDTO(id: UUID(), name: "Franz")

var mockPosters: [PosterResponseDTO] {
   return [
      PosterResponseDTO(
         id: UUID(),
         name: "Weihnachtsfeier",
         description: "Das ist das Plakat für unsere Weißnachtsfeier dieses Jahr und wir wollen versuchen so neue Mitglieder zu gewinnen.",
         imageUrl: "bild1"),
      PosterResponseDTO(
         id: UUID(),
         name: "Zirkus",
         description: "Das ist das Plakat für unseren Zirkus dieses Jahr und wir wollen versuchen so neue Mitglieder zu gewinnen.",
         imageUrl: "bild2"
      ),
      PosterResponseDTO(
         id: UUID(),
         name: "Frühlingsfest",
         description: "Das ist das Plakat für unser Frühlingsfest dieses Jahr und wir wollen versuchen so neue Mitglieder zu gewinnen.",
         imageUrl: "bild3"
      ),
      PosterResponseDTO(
         id: UUID(),
         name: "Herbstfest",
         description: "Das ist das Plakat für unser Herbstfest dieses Jahr und wir wollen versuchen so neue Mitglieder zu gewinnen.",
         imageUrl: "bild4"
      ),
   ]
}
//
//var mockPosters: [Poster] {
//   return [
//      Poster(
//         id: UUID(),
//         posterPositionIds: [mockPosterPosition1.id, mockPosterPosition5.id, mockPosterPosition3.id, mockPosterPosition6.id],
//         name: "Weihnachtsfeier",
//         description: "Das ist das Plakat für unsere Weißnachtsfeier dieses Jahr und wir wollen versuchen so neue Mitglieder zu gewinnen.",
//         imageBase64: "bild1"
//      ),
//      Poster(
//         id: UUID(),
//         posterPositionIds: [mockPosterPosition2.id, mockPosterPosition3.id],
//         name: "Zirkus",
//         description: "Das ist das Plakat für unseren Zirkus dieses Jahr und wir wollen versuchen so neue Mitglieder zu gewinnen.",
//         imageBase64: "bild2"
//      ),
//      Poster(
//         id: UUID(),
//         posterPositionIds: [mockPosterPosition4.id],
//         name: "Frühlingsfest",
//         description: "Das ist das Plakat für unser Frühlingsfest dieses Jahr und wir wollen versuchen so neue Mitglieder zu gewinnen.",
//         imageBase64: "bild3"
//      ),
//      Poster(
//         id: UUID(),
//         posterPositionIds: [mockPosterPosition3.id],
//         name: "Herbstfest",
//         description: "Das ist das Plakat für unser Herbstfest dieses Jahr und wir wollen versuchen so neue Mitglieder zu gewinnen.",
//         imageBase64: "bild4"
//      ),
//   ]
//}

public enum Status: String, Codable {
   case hung
   case takenDown
   case notDisplayed
   case expiresInOneDay
   case expired
}

let mockPosterPosition0 = PosterPositionResponseDTO(
   id: UUID(),
   latitude: 51.500603516488205,
   longitude: 6.545327532716446,
   expiresAt: Date.now,
   responsibleUsers: [mockUser1, mockUser2],
   status: "toHang")

let mockPosterPosition1: PosterPosition = PosterPosition( //poster1
   id: UUID(),
   responsibleUserIds: [mockIdentity1.id, mockIdentity2.id],
   latitude: 51.500603516488205,
   longitude: 6.545327532716446,
   status: Status.expired,
   imageBase64: "bild",
   expiresAt: Date.now,
   postedAt: Calendar.current.date(byAdding: .day, value: -7, to: Date())!
)
let mockPosterPosition2: PosterPosition = PosterPosition(
   id: UUID(),
   responsibleUserIds: [mockIdentity1.id],
   latitude: 0,
   longitude: 0,
   status: Status.expiresInOneDay,
   imageBase64: "bild",
   expiresAt: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
   postedAt: Calendar.current.date(byAdding: .day, value: -7, to: Date())!
)
let mockPosterPosition3: PosterPosition = PosterPosition( //poster1
   id: UUID(),
   responsibleUserIds: [mockIdentity1.id],
   latitude: 51.500903516488205,
   longitude: 6.545927532716446,
   status: Status.notDisplayed,
   imageBase64: "bild",
   expiresAt: Calendar.current.date(byAdding: .day, value: 16, to: Date())!,
   postedAt: Calendar.current.date(byAdding: .day, value: -7, to: Date())!
)
let mockPosterPosition4: PosterPosition = PosterPosition(
   id: UUID(),
   responsibleUserIds: [mockIdentity1.id],
   latitude: 0,
   longitude: 0,
   status: Status.hung,
   imageBase64: "bild",
   expiresAt: Calendar.current.date(byAdding: .day, value: 30, to: Date())!,
   postedAt: Calendar.current.date(byAdding: .day, value: -2, to: Date())!
)
let mockPosterPosition5: PosterPosition = PosterPosition( //poster1
   id: UUID(),
   responsibleUserIds: [mockIdentity1.id],
   latitude: 51.500653516488205,
   longitude: 6.545387532716446,
   status: Status.expired,
   imageBase64: "bild",
   expiresAt: Date.now,
   postedAt: Calendar.current.date(byAdding: .day, value: -7, to: Date())!
)
let mockPosterPosition6: PosterPosition = PosterPosition( //poster1
   id: UUID(),
   responsibleUserIds: [mockIdentity1.id],
   latitude: 51.500604516488205,
   longitude: 6.545322532716446,
   status: Status.takenDown,
   imageBase64: "bild",
   expiresAt: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
   postedAt: Calendar.current.date(byAdding: .day, value: -7, to: Date())!
)

var mockPosterPositions: [PosterPosition] {
   [mockPosterPosition2, mockPosterPosition4, mockPosterPosition1, mockPosterPosition5, mockPosterPosition3, mockPosterPosition6]
}
