//
//  PosterDetailViewModel.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 20.01.25.
//

// This file defines the view models used for handling posters and their associated positions
// It includes fetching, filtering, and sorting posters based on various conditions

import Foundation
import Combine
import PosterServiceDTOs
import MapKit
import MeetingServiceDTOs

// MARK: - Posters ViewModel
// This view model handles fetching posters, filtering them based on statuses, and sorting them
@MainActor
class PostersViewModel: ObservableObject {
   // Published properties to update the UI when data changes
    @Published var posters: [PosterResponseDTO] = []
   @Published var filteredPosters: [FilteredPoster2] = [] // Filtered posters based on tab selection
    @Published var selectedTab: Int = 0 { // Handles tab switching (active vs archived posters)
       didSet {
          Task {
             await filterPosters()
          }
       }
    }

   // Dictionary to store poster positions mapped by poster ID
    private var posterPositionsMap: [UUID: [PosterPositionResponseDTO]] = [:]

    init() {
        Task {
            await fetchPosters() // Fetch posters when the view model is initialized
        }
    }

   // Asynchronously fetches posters from the API and stores them in the posters array
    func fetchPosters() async {
        do {
            let fetchedPosters = try await PosterService.shared.fetchPostersAsync()
            self.posters = fetchedPosters
            await fetchPosterPositions()
        } catch {
            print("Error fetching posters: \(error)")
        }
    }

   // Fetches positions for each poster and updates the posterPositionsMap
    private func fetchPosterPositions() async {
        for poster in posters {
            do {
                let positions = try await PosterService.shared.fetchPosterPositionsAsync(for: poster.id)
                posterPositionsMap[poster.id] = positions
            } catch {
                print("Error fetching positions for poster \(poster.id): \(error)")
            }
        }
        await filterPosters() // Once positions are fetched, filter posters
    }
   
   // Filters posters based on their statuses and sorting criteria
   private func filterPosters() async {
      var updatedFilteredPosters: [FilteredPoster2] = []
      
      for poster in posters {
         guard let positions = posterPositionsMap[poster.id], !positions.isEmpty else { continue }
         
         do {
            let posterSummary = try await PosterService.shared.fetchPosterSummary(for: poster.id)
            
            // Determine if the poster is archived (all positions are taken down and expired since 3 days)
            let isArchived = positions.allSatisfy { position in
               position.status == .takenDown &&
               position.expiresAt <= Calendar.current.date(byAdding: .day, value: -3, to: Date())!
            }
            
            // Include posters in the appropriate tab (0 = active, 1 = archived)
            switch selectedTab {
            case 0 where !isArchived, 1 where isArchived:
               updatedFilteredPosters.append(FilteredPoster2(poster: poster, posterSummary: posterSummary))
            default:
               continue
            }
         } catch {
            print("Error fetching posterSummary: \(error)")
         }
      }
      
      // Sort posters by their next take-down date or overdue/hangs status
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

   }
}

// MARK: - Poster Detail ViewModel
// Fetches detailed data for a specific poster
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

   // Fetches detailed poster information and positions
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

// MARK: - Poster Position ViewModel
// Handles fetching and updating position details for a specific poster position
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
   
   // Fetches the position details and reverse geocodes the address
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
   
   // Hang a position with an image, latitude and longitude
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
   
   // Take down a position with an image
   func takeDownPosition(image: Data) async throws {
       guard let position = position else { throw NSError(domain: "Position not found", code: 404, userInfo: nil) }

       let takeDownDTO = TakeDownPosterPositionDTO(image: image)
       _ = try await PosterService.shared.takeDownPosition(positionId: position.id, dto: takeDownDTO)
   }
   
   // Report a damaged position with an image
   func reportDamagedPosition(image: Data) async throws {
      guard let position = position else { throw NSError(domain: "Position not found", code: 404, userInfo: nil) }
      
      let damagedDTO = ReportDamagedPosterPositionDTO(image: image)
      _ = try await PosterService.shared.reportDamagedPosition(positionId: position.id, dto: damagedDTO)
   }

   // Reverse geocoding function to fetch an address from coordinates
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





// MARK: - mock-data for preview and testing

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
