//
//  PostersViewModel.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 09.12.24.
//

import Foundation
import SwiftUI
import MeetingServiceDTOs
//import PosterServiceDTOs

extension GetIdentityDTO: @retroactive Identifiable {}
extension GetIdentityDTO: @retroactive Equatable {}
extension GetIdentityDTO: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    public static func == (lhs: GetIdentityDTO, rhs: GetIdentityDTO) -> Bool {
        return lhs.id == rhs.id
    }
}

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

var mockPosters: [Poster] {
   return [
      Poster(
         id: UUID(),
         posterPositionIds: [mockPosterPosition1.id, mockPosterPosition5.id, mockPosterPosition3.id, mockPosterPosition6.id],
         name: "Weihnachtsfeier",
         description: "Das ist das Plakat für unsere Weißnachtsfeier dieses Jahr und wir wollen versuchen so neue Mitglieder zu gewinnen.",
         imageBase64: "bild1"
      ),
      Poster(
         id: UUID(),
         posterPositionIds: [mockPosterPosition2.id, mockPosterPosition3.id],
         name: "Zirkus",
         description: "Das ist das Plakat für unseren Zirkus dieses Jahr und wir wollen versuchen so neue Mitglieder zu gewinnen.",
         imageBase64: "bild2"
      ),
      Poster(
         id: UUID(),
         posterPositionIds: [mockPosterPosition4.id],
         name: "Frühlingsfest",
         description: "Das ist das Plakat für unser Frühlingsfest dieses Jahr und wir wollen versuchen so neue Mitglieder zu gewinnen.",
         imageBase64: "bild3"
      ),
      Poster(
         id: UUID(),
         posterPositionIds: [mockPosterPosition3.id],
         name: "Herbstfest",
         description: "Das ist das Plakat für unser Herbstfest dieses Jahr und wir wollen versuchen so neue Mitglieder zu gewinnen.",
         imageBase64: "bild4"
      ),
   ]
}

public enum Status: String, Codable {
   case hung
   case takenDown
   case notDisplayed
   case expiresInOneDay
   case expired
}

let mockPosterPosition1: PosterPosition = PosterPosition(
   id: UUID(),
   responsibleUserIds: [mockIdentity1.id, mockIdentity2.id],
   latitude: 0,
   longitude: 0,
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
let mockPosterPosition3: PosterPosition = PosterPosition(
   id: UUID(),
   responsibleUserIds: [mockIdentity1.id],
   latitude: 0,
   longitude: 0,
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
let mockPosterPosition5: PosterPosition = PosterPosition(
   id: UUID(),
   responsibleUserIds: [mockIdentity1.id],
   latitude: 0,
   longitude: 0,
   status: Status.expired,
   imageBase64: "bild",
   expiresAt: Date.now,
   postedAt: Calendar.current.date(byAdding: .day, value: -7, to: Date())!
)
let mockPosterPosition6: PosterPosition = PosterPosition(
   id: UUID(),
   responsibleUserIds: [mockIdentity1.id],
   latitude: 0,
   longitude: 0,
   status: Status.takenDown,
   imageBase64: "bild",
   expiresAt: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
   postedAt: Calendar.current.date(byAdding: .day, value: -7, to: Date())!
)

var mockPosterPositions: [PosterPosition] {
   [mockPosterPosition2, mockPosterPosition4, mockPosterPosition1, mockPosterPosition5, mockPosterPosition3, mockPosterPosition6]
}

class PostersViewModel: ObservableObject {

    @Published var searchText: String = ""
    @Published var selectedTab: Int = 0
    @Published var meetings: [GetMeetingDTO] = []
   @Published var posters: [Poster] = []
   @Published var posterPositions: [PosterPosition] = []
    
    init() {
//       fetchPosters()
       posters = mockPosters
       posterPositions = mockPosterPositions
    }
    
    // Abruf der Poster von der API
//    func fetchPosters() {
//        Task {
//            do {
//                // Statischer Login zum Testen, bis die Funktion implementiert wurde.
//                try await AuthController.shared.login(email: "admin@kivop.ipv64.net", password: "admin")
//                let token = try await AuthController.shared.getAuthToken()
//                
//                // Poster abrufen
//                guard let url = URL(string: "https://kivop.ipv64.net/...") else {
//                    throw NSError(domain: "Invalid URL", code: 400, userInfo: nil)
//                }
//                
//                var request = URLRequest(url: url)
//                request.httpMethod = "GET"
//                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//                
//                let (data, response) = try await URLSession.shared.data(for: request)
//                
//                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//                    throw NSError(domain: "Failed to fetch posters", code: 500, userInfo: nil)
//                }
//                
//                do {
//                    let decoder = JSONDecoder()
//                    decoder.dateDecodingStrategy = .iso8601
//                    // Die Dekodierung und die Fehlerbehandlung innerhalb der Hauptwarteschlange
//                    DispatchQueue.main.async {
//                        do {
//                            let fetchedPosters = try decoder.decode([PosterResponseDTO].self, from: data)
//                            self.posters.append(contentsOf: fetchedPosters)
//                        } catch {
//                            print("Fehler beim Dekodieren der Posters: \(error.localizedDescription)")
//                        }
//                    }
//                }
//            } catch {
//                // Fehlerbehandlung auf dem Hauptthread
//                DispatchQueue.main.async {
//                    print("\(error.localizedDescription)")
//                }
//            }
//        }
//    }

   
   var posterExpiresDates: [UUID: Date] {
      var dates: [UUID: Date] = [:]
      for poster in posters {
         let positionsSorted = getPosterPositions(poster: poster).sorted(by: { $0.expiresAt < $1.expiresAt })
         dates[poster.id!] = positionsSorted.first?.expiresAt
      }
      return dates
   }
   
   var posterExpiresPositions: [UUID: PosterPosition] {
      var positions: [UUID: PosterPosition] = [:]
      for poster in posters {
         let positionsSorted = getPosterPositions(poster: poster).sorted(by: { $0.expiresAt < $1.expiresAt })
         positions[poster.id!] = positionsSorted.first
      }
      return positions
   }
   
   private func sortedPosters() -> [Poster] {
      // Sort the posters by their corresponding expiration dates
//      let sortedPosters = posters.sorted { poster1, poster2 in
//         guard let date1 = posterExpiresDates[poster1.id!],
//               let date2 = posterExpiresDates[poster2.id!] else {
//            return false
//         }
//         return date1 < date2
//      }
      
      let sortedPosters = posters.sorted { poster1, poster2 in
         guard let position1 = posterExpiresPositions[poster1.id!],
               let position2 = posterExpiresPositions[poster2.id!] else {
            return false
         }
         return position1.expiresAt < position2.expiresAt
      }
      
      return sortedPosters
   }

    // Filtert Sitzungen basierend auf dem Tab
   var filteredPosters: [Poster] {
       var currentPosters: [Poster] = []
       var archivedPosters: [Poster] = []
      let sortedPosters = sortedPosters()
       for poster in sortedPosters {
          if getPosterPositions(poster: poster).contains(where: { $0.status != .notDisplayed }) {
             currentPosters.append(poster)
          } else {
             archivedPosters.append(poster)
          }
       }
        switch selectedTab {
        case 0:
           return currentPosters
        case 1:
            return archivedPosters
        default:
            return []
        }
    }
   
   private func getPosterPositions(poster: Poster) -> [PosterPosition] {
      var posterPositions: [PosterPosition] = []
      for id in poster.posterPositionIds {
         posterPositions.append(mockPosterPositions.first { $0.id == id }!)
      }
      return posterPositions
   }
   
}
