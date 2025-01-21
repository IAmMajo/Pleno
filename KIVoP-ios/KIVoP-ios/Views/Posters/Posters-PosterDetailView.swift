//
//  PosterDetailView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 10.12.24.
//

import SwiftUI
import CoreLocation
import PosterServiceDTOs

struct Posters_PosterDetailView: View {
   
   @StateObject private var viewModel: PosterDetailViewModel
   @State private var selectedPosition: PosterPositionResponseDTO?
   
   @State private var address: String?
   @State private var isLoadingAddress = true
   
   @State private var showImage: Bool =  false
   @State private var isShowingPosition: Bool = false
   
   @State private var isLoading = false
   @State private var error: String?
   
   @State var optionTextMap: [UInt8: String] = [:]
   @State private var addresses: [UUID: String] = [:]
   
   @Environment(\.colorScheme) var colorScheme
   
   
   init(posterId: UUID) {
      _viewModel = StateObject(wrappedValue: PosterDetailViewModel(posterId: posterId))
   }
   
//   let locations: [Location] = [
//      Location(name: "Am Grabstein 6", coordinate: CLLocationCoordinate2D(latitude: 51.500603516488205, longitude: 6.545327532716446)),
//      Location(name: "Hinter der Obergasse 27", coordinate: CLLocationCoordinate2D(latitude: 51.504906516488205, longitude: 6.525927532716446)),
//      Location(name: "Baumhaus 5", coordinate: CLLocationCoordinate2D(latitude: 51.494653516488205, longitude: 6.525307532716446)),
//      Location(name: "Katerstraße 3", coordinate: CLLocationCoordinate2D(latitude: 51.495553516488205, longitude: 6.565227532716446))
//   ]
   
   func getDateColor(position: PosterPositionResponseDTO) -> Color {
      let status = position.status
      switch status {
      case "hangs":
         if position.expiresAt < Calendar.current.date(byAdding: .day, value: 1, to: Date())! {
            return .orange
         } else {
            return Color(UIColor.secondaryLabel)
         }
//      case "takenDown":
//         return Color(UIColor.secondaryLabel)
//      case "toHang":
//         return Color(UIColor.secondaryLabel)
      case "overdue":
         return .red
      default:
         return Color(UIColor.secondaryLabel)
      }
   }
   
   func getDateStatusText(position: PosterPositionResponseDTO) -> String {
      let status = position.status
      switch status {
      case "hangs":
         if position.expiresAt < Calendar.current.date(byAdding: .day, value: 1, to: Date())! {
            return "morgen überfällig"
         } else {
            return "hängt"
         }
      case "takenDown":
         return "abgehangen"
      case "toHang":
         return "hängt nicht"
      case "overdue":
         return "überfällig"
      default:
         return ""
      }
   }
   
   func locations(positions: [PosterPositionResponseDTO]) -> [Location] {
      positions.compactMap { position in
         guard let address = addresses[position.id] else { return nil }
         let adressName = String(address.split(separator: ", ").first ?? "")
         return Location(
            name: adressName,
            coordinate: CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
         )
      }
   }
   
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
//               placemark.administrativeArea,
//               placemark.country
            ].compactMap { $0 }.joined(separator: ", ")
            completion(address)
         } else {
            completion(nil)
         }
      }
   }
   
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
   
//   private func fetchAddress(latitude: Double, longitude: Double) {
//      getAddressFromCoordinates(latitude: latitude, longitude: longitude) { fetchedAddress in
//         DispatchQueue.main.async {
//            self.address = fetchedAddress
//            self.isLoadingAddress = false
//         }
//      }
//   }
   
   private func hangsTotalMap(positions: [PosterPositionResponseDTO]) -> [Int: Int] {
       let hangsCount = positions.filter { $0.status == "hangs" }.count
       let notTakenDownCount = positions.filter { $0.status != "takenDown" }.count
       return [hangsCount: notTakenDownCount]
   }
   
   private func takenDownTotalMap(positions: [PosterPositionResponseDTO]) -> [Int: Int] {
       let takenDownCount = positions.filter { $0.status == "takenDown" }.count
      let positionsCount = positions.count
      return [takenDownCount: positionsCount]
   }
   
    var body: some View {
       ScrollView {
          if let poster = viewModel.poster {
             VStack {
                HStack {
                   Text("Abhängedatum:")
                      .fontWeight(.semibold)
                      .padding(.trailing, -2)
                   if let expirationPosition = viewModel.positions.min(by: { $0.expiresAt < $1.expiresAt }) {
                      Text("\(DateTimeFormatter.formatDate(expirationPosition.expiresAt))")
                         .fontWeight(.semibold)
                         .foregroundStyle(getDateColor(position: expirationPosition))
                   } else {
                      Text("Keins vorhanden")
                         .fontWeight(.semibold)
                         .foregroundStyle(Color(UIColor.secondaryLabel))
                   }
                }.padding(.top, 5)
                
                if let uiImage = UIImage(data: poster.image) {
                   Image(uiImage: uiImage)
                      .resizable()
                      .aspectRatio(contentMode: .fit)
//                      .frame(maxWidth: 200, maxHeight: 200)
                   .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                   .frame(maxWidth: 200, maxHeight: 200)
                   .foregroundStyle(.gray.opacity(0.5))
                   .padding(.top, 10) .padding(.bottom, 10)
                   .onTapGesture {
                      showImage = true
                   }
                   .navigationDestination(isPresented: $showImage) {
                      FullImageView(uiImage: uiImage)
                   }
                }
                
                if !viewModel.positions.isEmpty {
                   let hangsTotalMap = hangsTotalMap(positions: viewModel.positions)
                   let takenDownTotalMap = takenDownTotalMap(positions: viewModel.positions)
                   HStack{
                      VStack{
                         CircularProgressView(value: hangsTotalMap.keys.first ?? 0, total: hangsTotalMap.values.first ?? 0, status: "hangs")
                            .frame(maxWidth: 45, maxHeight: 45)
                            .padding(.bottom, 5)
                         Text("Aufgehangen")
                            .font(.subheadline)
                            .foregroundStyle(Color(UIColor.label).opacity(0.6))
                      }
                      .padding(.leading, 35)
                      
                      Spacer()
                      
                      VStack{
                         CircularProgressView(value: takenDownTotalMap.keys.first ?? 0, total: takenDownTotalMap.values.first ?? 0, status: "takenDown")
                            .frame(maxWidth: 45, maxHeight: 45)
                            .padding(.bottom, 5)
                         Text("Abgehangen")
                            .font(.subheadline)
                            .foregroundStyle(Color(UIColor.label).opacity(0.6))
                      }
                      .padding(.trailing, 35)
                   }
                }
                
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
                
                
                Rectangle()
                   .frame(height: 215)
                   .overlay(
                     VStack {
                        MapPositionsView(locations: locations(positions: viewModel.positions))
                     }
                   )
                   .cornerRadius(10)
                   .padding(.horizontal)
                
                
                VStack (alignment: .leading, spacing: 6) {
                   Text("STANDORTE (\(viewModel.positions.count))")
                      .font(.footnote)
                      .foregroundStyle(Color(UIColor.secondaryLabel))
                      .padding(.leading, 32)
                   ZStack {
                      VStack {
                         ForEach (viewModel.positions, id: \.id) { position in
                            HStack {
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
                                  
                                  Text("\(DateTimeFormatter.formatDate(position.expiresAt))")
                                     .frame(maxWidth: .infinity, alignment: .leading)
                                     .font(.callout)
                                     .foregroundStyle(getDateColor(position: position))
                                  
                               }
                               Spacer()
                               Text(getDateStatusText(position: position))
                                  .font(.caption)
                                  .opacity(0.6)
                            }
                            .onTapGesture {
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
          } else if viewModel.isLoading {
             ProgressView("Loading...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
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
       }
       .navigationBarTitleDisplayMode(.inline)
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
             await viewModel.fetchPoster()
          }
       }
    }
}

#Preview {
//   @StateObject private var postersViewModel = PostersViewModel()

//   Posters_PosterDetailView(poster: mockPosters[0])
}
