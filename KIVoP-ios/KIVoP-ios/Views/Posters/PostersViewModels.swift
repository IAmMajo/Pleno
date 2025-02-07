//
//  PosterDetailViewModel.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 20.01.25.
//

import Foundation
import Combine
import PosterServiceDTOs
import MapKit
import MeetingServiceDTOs

@MainActor
class PostersViewModel: ObservableObject {
    @Published var posters: [PosterResponseDTO] = []
//   @Published var filteredPosters: [(poster: PosterResponseDTO, nextTakeDownPosition: PosterPositionResponseDTO, tohangCount: Int, expiredCount: Int)] = []
   @Published var filteredPosters: [FilteredPoster2] = []
    @Published var selectedTab: Int = 0 {
       didSet {
          Task {
             await filterPosters()
          }
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
        await filterPosters()
    }
   
   private func filterPosters() async {
      var updatedFilteredPosters: [FilteredPoster2] = []
      
      for poster in posters {
         guard let positions = posterPositionsMap[poster.id], !positions.isEmpty else { continue }
         
         do {
            let posterSummary = try await PosterService.shared.fetchPosterSummary(for: poster.id)
            
            // Check if the poster is archived
            let isArchived = positions.allSatisfy { position in
               position.status == .takenDown &&
               position.expiresAt <= Calendar.current.date(byAdding: .day, value: -3, to: Date())!
            }
            
            switch selectedTab {
            case 0 where !isArchived, 1 where isArchived:
               updatedFilteredPosters.append(FilteredPoster2(poster: poster, posterSummary: posterSummary))
            default:
               continue
            }
         } catch {
            print("Error fetching posterSummary: \(error)")
            // Fallback to mock data if fetching fails
//            updatedFilteredPosters.append(FilteredPoster2(poster: poster, posterSummary: mockPosterSummary))
         }
      }
      
      // Sorting logic after fetching all summaries
      filteredPosters = updatedFilteredPosters.sorted {
         if $0.posterSummary.hangs > 0 || $0.posterSummary.overdue > 0 {
            if $1.posterSummary.hangs > 0 || $1.posterSummary.overdue > 0 {
               return $0.posterSummary.nextTakeDown ?? Date() < $1.posterSummary.nextTakeDown ?? Date()
            } else {
               return true
            }
         } else if $1.posterSummary.hangs > 0 || $1.posterSummary.overdue > 0 {
            return false
         } else {
            return $0.posterSummary.nextTakeDown ?? Date() < $1.posterSummary.nextTakeDown ?? Date()
         }
      }
      
   
//   private func filterPosters() {
//       filteredPosters = posters.compactMap { poster in
//           guard let positions = posterPositionsMap[poster.id], !positions.isEmpty else { return nil }
//           
//           // Count the number of positions with specific statuses
//          let tohangCount = positions.filter { $0.status == .toHang }.count
//          let expiredCount = positions.filter { $0.status == .overdue }.count
//          
//          // Find the position with the earliest `expiresAt`
////          guard let nextTakeDownPosition = positions.min(by: { $0.expiresAt < $1.expiresAt }) else { return nil }
//          let nextTakeDownPositionDTO: PosterPositionResponseDTO?
//          // Reinitialization of nextTakeDownPosition to earliest expired position
//          if expiredCount > 0 {
//             let expiredPosition = positions.filter { $0.status == .overdue }
//             nextTakeDownPositionDTO = expiredPosition.min(by: { $0.expiresAt < $1.expiresAt })
//          } else {
//             nextTakeDownPositionDTO = positions.min(by: { $0.expiresAt < $1.expiresAt })
//          }
//          guard let nextTakeDownPosition = nextTakeDownPositionDTO else { return nil }
//          
//           // Check if the poster is archived
//           let isArchived = positions.allSatisfy { position in
//              position.status == .takenDown &&
//               position.expiresAt <= Calendar.current.date(byAdding: .day, value: -3, to: Date())!
//           }
//           
//           switch selectedTab {
//           case 0:
//               // Include only non-archived posters for the "Aktuell" tab
//               if !isArchived {
//                   return FilteredPoster(
//                       poster: poster,
//                       nextTakeDownPosition: nextTakeDownPosition,
//                       tohangCount: tohangCount,
//                       expiredCount: expiredCount
//                   )
//               }
//           case 1:
//               // Include only archived posters for the "Archiviert" tab
//               if isArchived {
//                   return FilteredPoster(
//                       poster: poster,
//                       nextTakeDownPosition: nextTakeDownPosition,
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
//           // Custom sorting: prioritize .hangs and .overdue, then by `expiresAt`
//          if $0.nextTakeDownPosition.status == .hangs || $0.nextTakeDownPosition.status == .overdue {
//             if $1.nextTakeDownPosition.status == .hangs || $1.nextTakeDownPosition.status == .overdue {
//                   return $0.nextTakeDownPosition.expiresAt < $1.nextTakeDownPosition.expiresAt
//               } else {
//                   return true
//               }
//          } else if $1.nextTakeDownPosition.status == .hangs || $1.nextTakeDownPosition.status == .overdue {
//               return false
//           } else {
//               return $0.nextTakeDownPosition.expiresAt < $1.nextTakeDownPosition.expiresAt
//           }
//       }
   }
}


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


@MainActor
class PosterPositionViewModel: ObservableObject {
   @Published var position: PosterPositionResponseDTO?
   @Published var address: String?
   @Published var isLoading = false
   @Published var error: String?
   
   private let posterId: UUID
   private let positionId: UUID
   
   init(posterId: UUID, positionId: UUID) {
      self.posterId = posterId
      self.positionId = positionId
   }

    func fetchPosition() async {
        isLoading = true
        error = nil
        do {
            // Fetch the position details
           position = try await PosterService.shared.fetchPosterPositionAsync(id: posterId, positionId: positionId)
            // Fetch the address if position details are available
            if let latitude = position?.latitude,
               let longitude = position?.longitude {
                await fetchAddress(latitude: latitude, longitude: longitude)
            }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
   
   func hangPosition(image: Data, latitude: Double?, longitude: Double?) async throws {
       guard let position = position else { throw NSError(domain: "Position not found", code: 404, userInfo: nil) }

      let hangDTO: HangPosterPositionDTO
      if latitude == nil && longitude == nil {
         hangDTO = HangPosterPositionDTO(image: image)
      } else {
         hangDTO = HangPosterPositionDTO(image: image, latitude: latitude, longitude: longitude)
      }
       _ = try await PosterService.shared.hangPosition(positionId: position.id, dto: hangDTO)
   }
   
   func takeDownPosition(image: Data) async throws {
       guard let position = position else { throw NSError(domain: "Position not found", code: 404, userInfo: nil) }

       let takeDownDTO = TakeDownPosterPositionDTO(image: image)
       _ = try await PosterService.shared.takeDownPosition(positionId: position.id, dto: takeDownDTO)
   }
   
   func reportDamagedPosition(image: Data) async throws {
      guard let position = position else { throw NSError(domain: "Position not found", code: 404, userInfo: nil) }
      
      let damagedDTO = ReportDamagedPosterPositionDTO(image: image)
      _ = try await PosterService.shared.reportDamagedPosition(positionId: position.id, dto: damagedDTO)
   }

    private func fetchAddress(latitude: Double, longitude: Double) async {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
               let postalCodeAndLocality = [
                  placemark.postalCode,
                  placemark.locality
               ]  .compactMap { $0 }
                  .joined(separator: " ")
               let address = [
                  placemark.name,
                  postalCodeAndLocality,
                  placemark.country
               ]  .compactMap { $0 }
                  .joined(separator: "\n")
               self.address = address
            } else {
                self.address = "Address not found"
            }
        } catch {
            print("Failed to fetch address: \(error)")
            self.address = "Error fetching address"
        }
    }
}






let mockIdentity1: GetIdentityDTO = GetIdentityDTO(id: UUID(), name: "Heinz-Peters")
let mockIdentity2: GetIdentityDTO = GetIdentityDTO(id: UUID(), name: "Franz")
let mockUser1: ResponsibleUsersDTO = ResponsibleUsersDTO(id: UUID(), name: "Heinz-Peters")
let mockUser2: ResponsibleUsersDTO = ResponsibleUsersDTO(id: UUID(), name: "Franz")

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
   status: .toHang)

let mockPosterSummary = PosterSummaryResponseDTO(hangs: 0, toHang: 0, overdue: 0, takenDown: 0, damaged: 0, nextTakeDown: Date.distantFuture)

//   let locations: [Location] = [
//      Location(name: "Am Grabstein 6", coordinate: CLLocationCoordinate2D(latitude: 51.500603516488205, longitude: 6.545327532716446)),
//      Location(name: "Hinter der Obergasse 27", coordinate: CLLocationCoordinate2D(latitude: 51.504906516488205, longitude: 6.525927532716446)),
//      Location(name: "Baumhaus 5", coordinate: CLLocationCoordinate2D(latitude: 51.494653516488205, longitude: 6.525307532716446)),
//      Location(name: "Katerstraße 3", coordinate: CLLocationCoordinate2D(latitude: 51.495553516488205, longitude: 6.565227532716446))
//   ]
