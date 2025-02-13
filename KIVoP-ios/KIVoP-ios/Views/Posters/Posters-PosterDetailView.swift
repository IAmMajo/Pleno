// This file is licensed under the MIT-0 License.
//
//  PosterDetailView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 10.12.24.
//

// This file defines the view that displays detailed information about a specific poster
// It includes fetching poster data, displaying images, poster locations, and handling navigation

import SwiftUI
import CoreLocation
import PosterServiceDTOs

struct Posters_PosterDetailView: View {
   // ViewModel to handle poster details and positions
   @StateObject private var viewModel: PosterDetailViewModel
   // Holds the selected position when a location is tapped
   @State private var selectedPosition: PosterPositionResponseDTO?
   
   // Address mapping for positions Ids
   @State private var addresses: [UUID: String] = [:]
   
   @State private var address: String?
   @State private var isLoadingAddress = true
   
   @State private var showImage: Bool =  false
   @State private var isShowingPosition: Bool = false
   @State private var isShowingFullMapSheet: Bool = false
   @State private var isLoading = false
   @State private var error: String?
   
   @Environment(\.colorScheme) var colorScheme
   
   
   init(posterId: UUID) {
      _viewModel = StateObject(wrappedValue: PosterDetailViewModel(posterId: posterId))
   }
   
   // MARK: - Helper Methods
   
   // Determines the text and color associated with a poster position status
   func getDateStatusText(position: PosterPositionResponseDTO) -> (text: String, color: Color) {
      switch position.status {
      case .hangs:
         if position.expiresAt < Calendar.current.date(byAdding: .day, value: 1, to: Date())! {
            return (NSLocalizedString("morgen überfällig", comment: ""), .orange)
         } else {
            return (NSLocalizedString("hängt", comment: ""), .blue)
         }
      case .takenDown:
         return (NSLocalizedString("abgehängt", comment: ""), .green)
      case .toHang:
         return (NSLocalizedString("hängt noch nicht", comment: ""), Color(UIColor.secondaryLabel))
      case .overdue:
         return (NSLocalizedString("überfällig", comment: ""), .red)
      case .damaged:
         return (NSLocalizedString("beschädigt", comment: ""), .yellow)
      }
   }
   
   // Converts poster positions into a list of locations with their respective coordinates and the matching positions
   func locationsPositions(positions: [PosterPositionResponseDTO]) -> [(location: Location, position: PosterPositionResponseDTO)] {
      positions.compactMap { position in
         let address = addresses[position.id] ?? "Kein Name"
         let adressName = String(address.split(separator: ", ").first ?? "")
         return (
            location: Location(
               name: adressName,
               coordinate: CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)),
            position: position
         )
      }
   }
   
   // Fetches the address for a given position
   func getAddressFromCoordinates(latitude: Double, longitude: Double, completion: @escaping (String?) -> Void) {
      let geocoder = CLGeocoder()
      let location = CLLocation(latitude: latitude, longitude: longitude)
      
      geocoder.reverseGeocodeLocation(location) { placemarks, error in
         if let error = error {
            print("Geocoding error: \(error.localizedDescription)")
            completion(nil)
         } else if let placemark = placemarks?.first {
            let address = [
               placemark.name,
               placemark.locality,
            ].compactMap { $0 }.joined(separator: ", ")
            completion(address)
         } else {
            completion(nil)
         }
      }
   }
   
   // Fetches the address for a given position
   private func fetchAddress(for position: PosterPositionResponseDTO) {
      let latitude = position.latitude
      let longitude = position.longitude
      getAddressFromCoordinates(latitude: latitude, longitude: longitude) { address in
         DispatchQueue.main.async {
            if let address = address {
               addresses[position.id] = address
            } else {
               addresses[position.id] = "Address not found"
            }
         }
      }
   }
   
   // Calculates how many positions of how many not taken down positions have the status .hangs
   private func hangsTotalMap(positions: [PosterPositionResponseDTO]) -> [Int: Int] {
      let hangsCount = positions.filter { $0.status != .takenDown && $0.status != .toHang }.count
      let notTakenDownCount = positions.filter { $0.status != .takenDown }.count
       return [hangsCount: notTakenDownCount]
   }
   
   // Calculates how many positions of all positions are taken down
   private func takenDownTotalMap(positions: [PosterPositionResponseDTO]) -> [Int: Int] {
      let takenDownCount = positions.filter { $0.status == .takenDown }.count
      let positionsCount = positions.count
      return [takenDownCount: positionsCount]
   }
   
   // MARK: - View Body
   var body: some View {
      VStack {
         if isLoading {
            ProgressView("Loading...")
         }
         ScrollView {
            if let poster = viewModel.poster {
               VStack {
                  // Poster expiration date
                  HStack {
                     Text("Abhängedatum:")
                        .fontWeight(.semibold)
                        .padding(.trailing, -2)
                     if let expirationPosition = viewModel.positions.min(by: { $0.expiresAt < $1.expiresAt }) {
                        Text("\(DateTimeFormatter.formatDate(expirationPosition.expiresAt))")
                           .fontWeight(.semibold)
                           .foregroundStyle(DateColorHelper.getDateColor(position: expirationPosition))
                     } else {
                        Text("Keins vorhanden")
                           .fontWeight(.semibold)
                           .foregroundStyle(Color(UIColor.secondaryLabel))
                     }
                  }.padding(.top, 5)
                  
                  // Poster image
                  ZStack {
                     if let uiImage = viewModel.posterImage {
                        Image(uiImage: uiImage)
                           .resizable()
                           .aspectRatio(contentMode: .fit)
                           .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                           .frame(maxWidth: 200, maxHeight: 200)
                           .foregroundStyle(.gray.opacity(0.2))
                           .padding(.top, 10) .padding(.bottom, 10)
                           .onTapGesture {
                              showImage = true
                           }
                           .navigationDestination(isPresented: $showImage) {
                              FullImageView(uiImage: uiImage)
                           }
                     } else {
                        ProgressView()
                           .frame(width: 200, height: 200)
                           .background(.gray.opacity(0.2))
                           .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                     }
                  }
                  .onAppear() {
                     // loads the image of the poster asynchronous
                     if viewModel.posterImage == nil {
                        viewModel.fetchPosterImage(for: poster.id)
                     }
                  }
                  
                  // displays circular progress views of all hanging and taken-down positions of the poster
                  if !viewModel.positions.isEmpty {
                     let hangsTotalMap = hangsTotalMap(positions: viewModel.positions)
                     let takenDownTotalMap = takenDownTotalMap(positions: viewModel.positions)
                     HStack{
                        VStack{
                           CircularProgressView(value: hangsTotalMap.keys.first ?? 0, total: hangsTotalMap.values.first ?? 0, status: .hangs)
                              .frame(maxWidth: 45, maxHeight: 45)
                              .padding(.bottom, 5)
                           Text("Aufgehängt")
                              .font(.subheadline)
                              .foregroundStyle(Color(UIColor.label).opacity(0.6))
                        }
                        .padding(.leading, 35)
                        
                        Spacer()
                        
                        VStack{
                           CircularProgressView(value: takenDownTotalMap.keys.first ?? 0, total: takenDownTotalMap.values.first ?? 0, status: .takenDown)
                              .frame(maxWidth: 45, maxHeight: 45)
                              .padding(.bottom, 5)
                           Text("Abgehängt")
                              .font(.subheadline)
                              .foregroundStyle(Color(UIColor.label).opacity(0.6))
                        }
                        .padding(.trailing, 35)
                     }
                  }
                  
                  // poster description
                  VStack (alignment: .leading, spacing: 6) {
                     Text("BESCHREIBUNG")
                        .font(.footnote)
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                        .padding(.leading, 32)
                     ZStack {
                        Text(poster.description ?? "")
                           .padding(.horizontal) .padding(.vertical, 12)
                           .frame(maxWidth: .infinity, alignment: .leading)
                     }
                     .background(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
                     .cornerRadius(10)
                     .padding(.horizontal)
                  }
                  .padding(.vertical)
                  
                  // displays all positions (and their status) of the poster on a map
                  Rectangle()
                     .frame(height: 215)
                     .overlay(
                        VStack {
                           MapPositionsView(posterImage: viewModel.posterImage ?? nil, locationsPositions: locationsPositions(positions: viewModel.positions))
                              .onTapGesture {
                                 isShowingFullMapSheet = true
                              }
                              .sheet(isPresented: $isShowingFullMapSheet) {
                                 FullMapPositionsSheet(locationsPositions: locationsPositions(positions: viewModel.positions), poster: poster, posterImage: viewModel.posterImage ?? nil)
                              }
                        }
                     )
                     .cornerRadius(10)
                     .padding(.horizontal)
                  
                  // displays all poster positions with some information
                  VStack (alignment: .leading, spacing: 6) {
                     Text("STANDORTE (\(viewModel.positions.count))")
                        .font(.footnote)
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                        .padding(.leading, 32)
                     ZStack {
                        VStack {
                           ForEach (viewModel.positions, id: \.id) { position in
                              HStack {
                                 // position adress
                                 VStack {
                                    if let address = addresses[position.id] {
                                       Text("\(address)")
                                          .frame(maxWidth: .infinity, alignment: .leading)
                                    } else {
                                       Text("Fetching address...")
                                          .frame(maxWidth: .infinity, alignment: .leading)
                                          .onAppear {
                                             fetchAddress(for: position)
                                          }
                                    }
                                    
                                    // take-down/expiresAt date of the position
                                    Text("\(DateTimeFormatter.formatDate(position.expiresAt))")
                                       .frame(maxWidth: .infinity, alignment: .leading)
                                       .font(.callout)
                                       .foregroundStyle(DateColorHelper.getDateColor(position: position))
                                    
                                 }
                                 Spacer()
                                 // position status
                                 Text(getDateStatusText(position: position).text)
                                    .font(.caption)
                                    .foregroundStyle(getDateStatusText(position: position).color)
                              }
                              .contentShape(Rectangle())
                              .onTapGesture { // on tap: navigate to selected position
                                 selectedPosition = position
                                 isShowingPosition = true
                              }
                              if position.id != viewModel.positions.last?.id {
                                 Divider()
                                    .padding(.vertical, 2)
                              }
                           }
                        }
                        .padding(.horizontal) .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                     }
                     .background(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
                     .cornerRadius(10)
                     .padding(.horizontal)
                  }
                  .padding(.vertical)
               }
            } else if let error = viewModel.error {
               Text("Error: \(error)")
                  .foregroundColor(.red)
            } else {
               Text("No poster data available.")
                  .foregroundColor(.secondary)
            }
            
         }
         .refreshable {
            await viewModel.fetchPoster()
            if let poster = viewModel.poster {
               viewModel.fetchPosterImage(for: poster.id)
            }
         }
         .navigationBarTitleDisplayMode(.inline)
         // navigating to selected position
         .navigationDestination(isPresented: $isShowingPosition) {
            if let position = selectedPosition {
               if let address = addresses[position.id] {
                  let adressName = String(address.split(separator: ", ").first ?? "")
                  if let poster = viewModel.poster {
                     Posters_PositionView(posterId: poster.id, positionId: position.id)
                        .navigationTitle(adressName)
                  }
               }
            }
         }
         .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
         .onAppear {
            Task {
               isLoading = true
               await viewModel.fetchPoster()
               isLoading = false
            }
         }
      }
   }
}

#Preview {
   
}
