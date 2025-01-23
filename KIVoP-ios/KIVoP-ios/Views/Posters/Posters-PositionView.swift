//
//  Posters_PositionView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 11.12.24.
//

import SwiftUI
import MeetingServiceDTOs
import MapKit
import UIKit
import PosterServiceDTOs
//import CoreHaptics

struct Posters_PositionView: View {
   
   @StateObject private var viewModel: PosterPositionViewModel
   
   init(posterId: UUID, positionId: UUID) {
      _viewModel = StateObject(wrappedValue: PosterPositionViewModel(posterId: posterId, positionId: positionId))
   }
   
//   @State var name: String = "Name"
//   @State var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 51.500603516488205, longitude: 6.545327532716446)
   
   @State private var currentCoordinates: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 51.500603516488205, longitude: 6.545327532716446)
   
   @State private var myId: UUID?
   @State private var address: String?
   @State private var isLoadingAddress = true
   
   @State private var isGoogleMapsInstalled = false
   @State private var isWazeInstalled = false
   
   @State private var isFullMapView: Bool = false
   @State private var showMapOptions: Bool = false
   @State private var shareLocation = false
   @State private var showTakeDownAlert = false
   @State private var showUndoTakeDownAlert = false
   @State private var copiedToClipboard: Bool = false
   @State private var tappedCopyButton: Bool = false
   @FocusState private var isFocused: Bool
//   @State private var text = "Sample text"
   @Environment(\.dismiss) private var dismiss
   @Environment(\.colorScheme) var colorScheme
   
   
   func getAddressFromCoordinates(latitude: Double, longitude: Double, completion: @escaping (String?) -> Void) {
      let geocoder = CLGeocoder()
      let location = CLLocation(latitude: latitude, longitude: longitude)
      
      geocoder.reverseGeocodeLocation(location) { placemarks, error in
         if let error = error {
            print("Geocoding error: \(error.localizedDescription)")
            completion(nil)
         } else if let placemark = placemarks?.first {
            let postalCodeAndLocality = [
               placemark.postalCode,
               placemark.locality
            ].compactMap { $0 }.joined(separator: " ")
            let address = [
               placemark.name,
               postalCodeAndLocality,
               placemark.country
            ].compactMap { $0 }.joined(separator: "\n")
            completion(address)
         } else {
            completion(nil)
         }
      }
   }
   
   private func fetchAddress(latitude: Double, longitude: Double) {
      getAddressFromCoordinates(latitude: latitude, longitude: longitude) { fetchedAddress in
         DispatchQueue.main.async {
            self.address = fetchedAddress
            self.isLoadingAddress = false
         }
      }
   }
   
   func formatDate(_ date: Date) -> String {
      let date = Date() // Current date
      let formatter = DateFormatter()
      formatter.dateFormat = "dd.MM.yy"
      let formattedDate = formatter.string(from: date)
      return formattedDate
   }
   
   var body: some View {
      VStack {
         if viewModel.isLoading {
            ProgressView()
         }
         if let position = viewModel.position,
            let address = viewModel.address {
            ScrollView {
               VStack {
                  MapView(name: String(address.split(separator: "\n").first ?? ""), coordinate: currentCoordinates!)
                     .frame(height: 250)
                     .onTapGesture {
                        //                      showMapOptions = true
                        isFullMapView = true
                     }
                     .navigationDestination(isPresented: $isFullMapView) { FullMapView(address: address, name: String(address.split(separator: "\n").first ?? ""), coordinate: currentCoordinates ?? CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude))}
                  
                  CircleImageView(
                     position: position,
                     isResponsible: isResponsible(),
                     currentCoordinates: $currentCoordinates,
                     onUpdate: { image, coordinates in
                        Task {
                           do {
                              try await viewModel.hangPosition(image: image)
                              print("new coordinates: \(coordinates)")
                              await viewModel.fetchPosition()
                           } catch {
                              print("Error hanging position: \(error)")
                           }
                           await viewModel.fetchPosition() //wegmachen evtl sobald server error behoben wurde?
                        }
                     }
                  )
                  .padding(.top, -95)
                  .shadow(radius: 5)
                  
                  HStack {
                     Text("Abhängedatum:")
                        .foregroundStyle(Color(UIColor.label).opacity(0.75))
                        .fontWeight(.semibold)
                        .padding(.trailing, -2)
                     
                     Text("\(DateTimeFormatter.formatDate(position.expiresAt))")
                        .fontWeight(.semibold)
                        .foregroundStyle(DateColorHelper.getDateColor(position: position))
                  }.padding(.top, 10)
                  
                  VStack{
                     ProgressInfoView(position: position)
                        .padding(.leading) .padding(.trailing)
                        .padding(.top, 8) .padding(.bottom, 8)
                     
                     ProgressBarView(position: position)
                        .padding(.leading) .padding(.trailing)
                     if position.status == "toHang" {
                        Text("Mache jetzt ein Foto des aufgehängten Plakats und bestätige die Position")
                           .font(.system(size: 10))
                           .foregroundStyle(.secondary)
                     }
                  }
                  
                  VStack (alignment: .leading, spacing: 6) {
                     Text("VERANTWORTLICHE (\(position.responsibleUsers.count))")
                        .font(.footnote)
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                        .padding(.leading, 32)
                     ZStack {
                        VStack {
                           ForEach (position.responsibleUsers, id: \.id) { user in
                              HStack {
                                 UserProfileImageView(userId: user.id)
                                 Text(user.name)
                                 Spacer()
                                 
                                 if position.postedBy == user.name || position.removedBy == user.name {
                                    VStack {
                                       if position.postedBy  == user.name {
                                          let date = position.postedAt ?? Date()
                                          Text("aufgehängt am \(formatDate(date))")
                                       }
                                       if position.removedBy == user.name {
                                          let date = position.removedAt ?? Date()
                                          Spacer()
                                          Text("abgehängt am \(formatDate(date))")
                                       }
                                    }
                                    .font(.footnote)
                                    .foregroundStyle(Color(UIColor.secondaryLabel))
                                 }
                              }
                              if user.id != position.responsibleUsers.last?.id {
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
                  
                  
                  VStack (alignment: .leading, spacing: 6) {
                     Text("ADRESSE IN DER NÄHE")
                        .font(.footnote)
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                        .padding(.leading, 32)
                     ZStack {
                        VStack {
                           HStack(spacing: 0) {
                              Text(address)
                                 .textSelection(.enabled)
                              
                              Spacer()
                              
                              VStack {
                                 Button(action: { showMapOptions = true }) {
                                    Image(systemName: "square.and.arrow.up")
                                 }
                                 .buttonStyle(PlainButtonStyle())
                                 .foregroundStyle(.blue)
                                 .frame(width: 25, height: 25)
                                 .padding(.top, 8)
                                 
                                 Spacer()
                              }
                           }
                           
                           Divider().padding(.vertical, 2)
                           
                           HStack {
                              Text("\(String(format: "%.6f", position.latitude))° N, \(String(format: "%.6f", position.longitude))° E")
                                 .textSelection(.enabled)
                              
                              Spacer()
                              
                              Button(action: {
                                 tappedCopyButton.toggle()
                                 UIPasteboard.general.string = "\(String(format: "%.6f", position.latitude))° N, \(String(format: "%.6f", position.longitude))° E"
                                 withAnimation(.snappy) {
                                    copiedToClipboard = true
                                 }
                                 DispatchQueue.main.asyncAfter (deadline: .now() + 1.8) {
                                    withAnimation(.snappy) {
                                       copiedToClipboard = false
                                    }
                                 }
                              }) {
                                 Image(systemName: "document.on.document")
                              }
                              .buttonStyle(PlainButtonStyle())
                              .foregroundStyle(.blue)
                              .frame(width: 25, height: 25)
                              .sensoryFeedback(.success, trigger: tappedCopyButton)
                           }
                        }
                        .padding(.horizontal) .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                     }
                     .background(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
                     .cornerRadius(10)
                     .padding(.horizontal)
                  }
                  .overlay {
                     if copiedToClipboard {
                        Text ("In Zwischenablage kopiert") // Copied to Clipboard
                           .font(.system(.body, design: .rounded, weight: .semibold))
                           .foregroundStyle(.white)
                           .padding ()
                           .background(Color.blue.cornerRadius(12))
                           .padding(.bottom)
                           .shadow(radius: 5)
                           .transition(.move (edge: .bottom))
                           .frame(maxHeight: .infinity, alignment: .bottom)
                     }
                  }
   
               }
               .confirmationDialog("\(address)\n\(position.latitude), \(position.longitude)", isPresented: $showMapOptions, titleVisibility: .visible) {
                  Button("Öffnen mit Apple Maps") {
                     NavigationAppHelper.shared.openInAppleMaps(
                        name: String(address.split(separator: "\n").first ?? ""),
                        coordinate: currentCoordinates!
                     )
                  }
                  if isGoogleMapsInstalled {
                     Button("Öffnen mit Google Maps") {
                        NavigationAppHelper.shared.openInGoogleMaps(
                           name: String(address.split(separator: "\n").first ?? ""),
                           coordinate: currentCoordinates!)
                     }
                  }
                  if isWazeInstalled {
                     Button("Öffnen mit Waze") {
                        NavigationAppHelper.shared.openInWaze(coordinate: currentCoordinates!)
                     }
                  }
                  Button("Teilen...") {
                     shareLocation = true
                  }
                  Button("Abbrechen", role: .cancel) {}
               }
               .sheet(isPresented: $shareLocation) {
                  //                ShareView(address: address ?? "Adresse", coordinate: currentCoordinates!)
                  //                   .presentationDetents([.medium, .large])
                  //                   .presentationDragIndicator(.hidden)
                  ShareSheet(activityItems: [formattedShareText()])
                     .presentationDetents([.medium, .large])
                     .presentationDragIndicator(.hidden)
               }
            }
            .refreshable {
               loadMyId()
               await viewModel.fetchPosition()
            }
            if (position.status != "toHang" && isResponsible()) {
               Button {
                  if (position.status != "takenDown") {
                     showTakeDownAlert = true
                  } else {
                     showUndoTakeDownAlert = true
                  }
               } label: {
                  Text(position.status != "takenDown" ? "Abhängen bestätigen" : "Abhängen zurückziehen")
                     .foregroundStyle(position.status != "takenDown" ? Color(UIColor.systemBackground) : Color.red)
                     .fontWeight(.semibold)
                     .frame(maxWidth: .infinity)
               }
               .background(position.status != "takenDown" ? Color.red : Color.gray.opacity(0.2))
               .cornerRadius(10)
               .padding(.leading) .padding(.trailing)
               .padding(.top, 5)
               .buttonStyle(.bordered)
               .controlSize(.large)
               .alert(isPresented: Binding(
                  get: { showTakeDownAlert || showUndoTakeDownAlert },
                  set: { if !$0 { showTakeDownAlert = false; showUndoTakeDownAlert = false } }
               )) {
                  if showTakeDownAlert {
                     return Alert(
                        title: Text("Plakat abhängen?"),
                        message: Text("Bist du sicher, dass du das Plakat abhängen möchtest?"),
                        primaryButton: .default(Text("Ja")) {
                           Task {
                              // Perform "Plakat abhängen" action here
                              do {
                                 try await viewModel.takeDownPosition(image: position.image ?? Data())
                                 await viewModel.fetchPosition()
                              } catch {
                                 print("Error taking down position: \(error)")
                              }
                              await viewModel.fetchPosition() //wegmachen evtl sobald server error behoben wurde?
                           }
                        },
                        secondaryButton: .cancel(Text("Nein"))
                     )
                  } else if showUndoTakeDownAlert {
                     return Alert(
                        title: Text("Abhängen zurückziehen?"),
                        message: Text("Bist du sicher, dass du das Abhängen zurückziehen möchtest? Das Plakat gilt danach wieder als aufgehängt."),
                        primaryButton: .default(Text("Ja")) {
                           Task {
                              // Perform "Abhängen zurückziehen" action here
                              do {
                                 try await viewModel.hangPosition(image: position.image ?? Data()) //Koordinaten ergänzen
                                 await viewModel.fetchPosition()
                              } catch {
                                 print("Error hanging position after taking it down: \(error)")
                              }
                              await viewModel.fetchPosition() //wegmachen evtl sobald server error behoben wurde?
                           }
                        },
                        secondaryButton: .cancel(Text("Nein"))
                     )
                  } else {
                     return Alert(title: Text("Unknown Action")) // Fallback case
                  }
               }
            }
         } else if viewModel.isLoading {
//            ProgressView("Loading...")
//               .frame(maxWidth: .infinity, maxHeight: .infinity)
//               .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
        } else if let error = viewModel.error {
            Text("Error: \(error)")
                .foregroundColor(.red)
        } else {
            Text("No poster data available.")
                .foregroundColor(.secondary)
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
      .onAppear {
         let installedApps = NavigationAppHelper.shared.checkInstalledApps()
         isGoogleMapsInstalled = installedApps.isGoogleMapsInstalled
         isWazeInstalled = installedApps.isWazeInstalled
         
         //          fetchAddress(latitude: currentCoordinates!.latitude, longitude: currentCoordinates!.longitude)
         Task {
            loadMyId()
            await viewModel.fetchPosition()
            if let position = viewModel.position {
               currentCoordinates = CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
            }
         }
      }
      .onChange(of: currentCoordinates) { oldValue, newValue in
         //          fetchAddress(latitude: currentCoordinates!.latitude, longitude: currentCoordinates!.longitude)
      }
   }
   
   private func formattedShareText() -> String {
      //      """
      //      \(address ?? "")
      //      \(coordinate.latitude), \(coordinate.longitude)
      //      """
      if let address = viewModel.address {
         return
      """
      \(address)
      """
      }
      return ""
   }
   
   func isResponsible() -> Bool {
      guard let myId = myId else { return false }
      return viewModel.position?.responsibleUsers.contains(where: {
         $0.id == myId
      }) ?? false
   }
   
   func loadMyId() {
      MainPageAPI.fetchUserProfile { result in
         DispatchQueue.main.async {
            switch result {
            case .success(let profile):
               self.myId = profile.uid
            case .failure(let error):
               print("Fehler beim Laden des Profils (PositionView): \(error.localizedDescription)")
            }
         }
      }
   }
}

#Preview {
//   Posters_PositionView(position: mockPosterPosition1)
}
