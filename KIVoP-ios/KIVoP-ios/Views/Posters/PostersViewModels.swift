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
       .sorted(by: { $0.earliestPosition.expiresAt < $1.earliestPosition.expiresAt })
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
   
   func refreshPosition() async {
       guard var position = position else { return }
       do {
           position = try await PosterService.shared.fetchPosterPositionAsync(
               id: position.posterId ?? UUID(),
               positionId: position.id
           )
       } catch {
           print("Failed to refresh position: \(error)")
       }
   }
   
   func updatePosition(image: Data, latitude: Double, longitude: Double) async throws {
       guard let position = position else { throw NSError(domain: "Position not found", code: 404, userInfo: nil) }

       let updateDTO = UpdatePosterPositionDTO(
           posterId: position.posterId,
           latitude: latitude,
           longitude: longitude,
           image: image
       )

       self.position = try await PosterService.shared.updatePosition(
           posterId: position.posterId ?? UUID(),
           positionId: position.id,
           dto: updateDTO
       )
   }
   
   func hangPosition() async throws {
       guard let position = position else { throw NSError(domain: "Position not found", code: 404, userInfo: nil) }

       let hangDTO = HangPosterPositionDTO(image: position.image ?? Data())
       _ = try await PosterService.shared.hangPosition(positionId: position.id, dto: hangDTO)
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

//var mockPosters: [PosterResponseDTO] {
//   return [
//      PosterResponseDTO(
//         id: UUID(),
//         name: "Weihnachtsfeier",
//         description: "Das ist das Plakat für unsere Weißnachtsfeier dieses Jahr und wir wollen versuchen so neue Mitglieder zu gewinnen.",
//         image: "bild1"),
//      PosterResponseDTO(
//         id: UUID(),
//         name: "Zirkus",
//         description: "Das ist das Plakat für unseren Zirkus dieses Jahr und wir wollen versuchen so neue Mitglieder zu gewinnen.",
//         image: "bild2"
//      ),
//      PosterResponseDTO(
//         id: UUID(),
//         name: "Frühlingsfest",
//         description: "Das ist das Plakat für unser Frühlingsfest dieses Jahr und wir wollen versuchen so neue Mitglieder zu gewinnen.",
//         image: "bild3"
//      ),
//      PosterResponseDTO(
//         id: UUID(),
//         name: "Herbstfest",
//         description: "Das ist das Plakat für unser Herbstfest dieses Jahr und wir wollen versuchen so neue Mitglieder zu gewinnen.",
//         image: "bild4"
//      ),
//   ]
//}
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

//let mockPosterPosition1: PosterPosition = PosterPosition( //poster1
//   id: UUID(),
//   responsibleUserIds: [mockIdentity1.id, mockIdentity2.id],
//   latitude: 51.500603516488205,
//   longitude: 6.545327532716446,
//   status: Status.expired,
//   imageBase64: "bild",
//   expiresAt: Date.now,
//   postedAt: Calendar.current.date(byAdding: .day, value: -7, to: Date())!
//)
//let mockPosterPosition2: PosterPosition = PosterPosition(
//   id: UUID(),
//   responsibleUserIds: [mockIdentity1.id],
//   latitude: 0,
//   longitude: 0,
//   status: Status.expiresInOneDay,
//   imageBase64: "bild",
//   expiresAt: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
//   postedAt: Calendar.current.date(byAdding: .day, value: -7, to: Date())!
//)
//let mockPosterPosition3: PosterPosition = PosterPosition( //poster1
//   id: UUID(),
//   responsibleUserIds: [mockIdentity1.id],
//   latitude: 51.500903516488205,
//   longitude: 6.545927532716446,
//   status: Status.notDisplayed,
//   imageBase64: "bild",
//   expiresAt: Calendar.current.date(byAdding: .day, value: 16, to: Date())!,
//   postedAt: Calendar.current.date(byAdding: .day, value: -7, to: Date())!
//)
//let mockPosterPosition4: PosterPosition = PosterPosition(
//   id: UUID(),
//   responsibleUserIds: [mockIdentity1.id],
//   latitude: 0,
//   longitude: 0,
//   status: Status.hung,
//   imageBase64: "bild",
//   expiresAt: Calendar.current.date(byAdding: .day, value: 30, to: Date())!,
//   postedAt: Calendar.current.date(byAdding: .day, value: -2, to: Date())!
//)
//let mockPosterPosition5: PosterPosition = PosterPosition( //poster1
//   id: UUID(),
//   responsibleUserIds: [mockIdentity1.id],
//   latitude: 51.500653516488205,
//   longitude: 6.545387532716446,
//   status: Status.expired,
//   imageBase64: "bild",
//   expiresAt: Date.now,
//   postedAt: Calendar.current.date(byAdding: .day, value: -7, to: Date())!
//)
//let mockPosterPosition6: PosterPosition = PosterPosition( //poster1
//   id: UUID(),
//   responsibleUserIds: [mockIdentity1.id],
//   latitude: 51.500604516488205,
//   longitude: 6.545322532716446,
//   status: Status.takenDown,
//   imageBase64: "bild",
//   expiresAt: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
//   postedAt: Calendar.current.date(byAdding: .day, value: -7, to: Date())!
//)
//
//var mockPosterPositions: [PosterPosition] {
//   [mockPosterPosition2, mockPosterPosition4, mockPosterPosition1, mockPosterPosition5, mockPosterPosition3, mockPosterPosition6]
//}
