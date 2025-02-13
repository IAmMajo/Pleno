// This file is licensed under the MIT-0 License.
//
//  Posters_PositionView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 11.12.24.
//

// Posters-PositionView.swift
// Displays detailed information about a specific poster position, including map, responsible users, and actions.

import SwiftUI
import MeetingServiceDTOs
import MapKit
import UIKit
import PosterServiceDTOs

struct Posters_PositionView: View {
   
   let posterId: UUID
   @StateObject private var viewModel: PosterPositionViewModel /// ViewModel responsible for managing poster position data
   
   // Initialize the ViewModel with poster and position IDs
   init(posterId: UUID, positionId: UUID) {
      _viewModel = StateObject(wrappedValue: PosterPositionViewModel(posterId: posterId, positionId: positionId))
      self.posterId = posterId
   }
   
   // MARK: - UI State Variables
   @State private var currentCoordinates: CLLocationCoordinate2D?
   @State private var myId: UUID?
   @State private var address: String?
   @State private var isLoadingAddress = true
   @State private var isLoading = false
   
   // UI Modals & Alerts
   @State private var showMapOptions: Bool = false
   @State private var isGoogleMapsInstalled = false
   @State private var isWazeInstalled = false
   @State private var isShowingFullMapSheet: Bool = false
   @State private var shareLocation = false
   @State private var showTakeDownAlert = false
   @State private var showUndoTakeDownAlert = false
   @State private var showReportDamageAlert = false
   @State private var showCamera = false
   @State private var selectedImage: UIImage? = nil
   
   @FocusState private var isFocused: Bool
   @Environment(\.dismiss) private var dismiss
   @Environment(\.colorScheme) var colorScheme
   
   
   // MARK: - Fetch Address Helper
   // Converts latitude & longitude to a address using reverse geocoding
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
   
   // Fetches and updates the address from the given coordinates
   private func fetchAddress(latitude: Double, longitude: Double) {
      getAddressFromCoordinates(latitude: latitude, longitude: longitude) { fetchedAddress in
         DispatchQueue.main.async {
            self.address = fetchedAddress
            self.isLoadingAddress = false
         }
      }
   }
   
   // MARK: - View Body
   var body: some View {
      VStack {
         if let position = viewModel.position,
            let address = viewModel.address {
            ScrollView {
               VStack {
                  // Map with position with a tappable option for full view
                  MapView(name: String(address.split(separator: "\n").first ?? ""), coordinate: currentCoordinates!, posterId: posterId)
                     .frame(height: 250)
                     .onTapGesture {
                        isShowingFullMapSheet = true
                     }
                     .sheet(isPresented: $isShowingFullMapSheet) {
                        FullMapSheet(posterId: posterId, address: address, name: String(address.split(separator: "\n").first ?? ""), coordinate: currentCoordinates ?? CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude))
                     }
                  
                  // Position image (or placeholder) with option to hang the position
                  CircleImageView(
                     position: position,
                     positionImage: viewModel.positionImageData != nil ? UIImage(data: viewModel.positionImageData!) : nil,
                     isResponsible: isResponsible(),
                     currentCoordinates: $currentCoordinates,
                     onUpdate: { image, coordinates in
                        Task {
                           await handleImageUpdate(positionId: position.id, image: image, coordinates: coordinates)
                        }
                     }
                  )
                  .onAppear() {
                     // loads the image of the position asynchronous
                     if viewModel.positionImageData == nil {
                        viewModel.fetchPositionImage(for: position.id)
                     }
                  }
                  .padding(.top, -95)
                  .shadow(radius: 5)
                  
                  // Expiration date
                  HStack {
                     Text("Abhängedatum:")
                        .foregroundStyle(Color(UIColor.label).opacity(0.75))
                        .fontWeight(.semibold)
                        .padding(.trailing, -2)
                     
                     Text("\(DateTimeFormatter.formatDate(position.expiresAt))")
                        .fontWeight(.semibold)
                        .foregroundStyle(DateColorHelper.getDateColor(position: position))
                  }.padding(.top, 10)
                  
                  // Progress info
                  VStack{
                     ProgressInfoView(position: position)
                        .padding(.leading) .padding(.trailing)
                        .padding(.top, 8) .padding(.bottom, 8)
                     
                     ProgressBarView(position: position)
                        .padding(.leading) .padding(.trailing)
                     if position.status == .toHang {
                        Text("Mache jetzt ein Foto des aufgehängten Plakats und bestätige die Position")
                           .font(.system(size: 10))
                           .foregroundStyle(.secondary)
                     }
                  }
                  
                  // Responsible users
                  ResponsibleUsersView(position: position)
                  
                  // Address and coordinates
                  AddressView(position: position, address: address, showMapOptions: $showMapOptions)
   
               }
               // Open address/coordinates in app or share dialog
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
                  ShareSheet(activityItems: [formattedShareText()])
                     .presentationDetents([.medium, .large])
                     .presentationDragIndicator(.hidden)
               }
               
               // Report damage button (if applicable)
               if position.status == .hangs { ReportDamageButton(position: position) }
               
            }
            .refreshable {
               loadMyId()
               await viewModel.fetchPosition()
               viewModel.fetchPositionImage(for: position.id)
            }
            
            // Take down (or undo take down) button
            if (position.status != .toHang && isResponsible()) { TakeDownButton(position: position) }
            
         } else if viewModel.isLoading {
            ProgressView("Loading...")
               .frame(maxWidth: .infinity, maxHeight: .infinity)
               .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
        } else if let error = viewModel.error {
            Text("Error: \(error)")
                .foregroundColor(.red)
        } else {
            Text("No poster data available.")
                .foregroundColor(.secondary)
        }
      }
      .overlay {
         if isLoading {
            ProgressView("Loading...")
               .tint(Color(UIColor.label))
               .frame(maxWidth: .infinity, maxHeight: .infinity)
               .background(.black.opacity(0.3))
         }
      }
      .navigationBarTitleDisplayMode(.inline)
      .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
      .onAppear {
         // checks if Google Maps or Waze is installed
         let installedApps = NavigationAppHelper.shared.checkInstalledApps()
         isGoogleMapsInstalled = installedApps.isGoogleMapsInstalled
         isWazeInstalled = installedApps.isWazeInstalled
         // loads position and sets currentCoordinates
         Task {
            loadMyId()
            await viewModel.fetchPosition()
            if let position = viewModel.position {
               currentCoordinates = CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude)
            }
         }
      }
   }
   
   // MARK: - Report Damage Button
   @ViewBuilder
   private func ReportDamageButton(position: PosterPositionResponseDTO) -> some View {
      HStack {
         Image(systemName: "exclamationmark.circle")
         Text("Beschädigung melden")
         Spacer()
      }
      .foregroundStyle(Color.red)
      .padding()
      .onTapGesture {
         showReportDamageAlert = true
      }
      .alert(isPresented: $showReportDamageAlert) {
         return Alert(
            title: Text("Beschädigung melden?"),
            message: Text("Bestätige mit einem Bild, dass das Plakat beschädigt wurde, oder es nicht mehr an der vorgesehenen Stelle hängt."),
            primaryButton: .default(Text("Verstanden")) {
               self.showCamera.toggle()
            },
            secondaryButton: .cancel(Text("Abbrechen"))
         )
      }
      .fullScreenCover(isPresented: $showCamera) {
         accessCameraView(
            isDamageReport: true,
            selectedImage: $selectedImage,
            showCamera: $showCamera,
            currentCoordinates: $currentCoordinates
         ) {
            if let image = selectedImage,
               let imageData = image.jpegData(compressionQuality: 0.8)
            {
               Task {
                  do {
                     try await viewModel.reportDamagedPosition(image: imageData)
                  } catch {
                     print("Error reporting damaged position: \(error)")
                  }
                  await viewModel.fetchPosition()
                  viewModel.fetchPositionImage(for: position.id)
               }
            }
         }
         .background(.black)
      }
   }
   
   // MARK: - Take Down (or undo Take Down) Button
   @ViewBuilder
   private func TakeDownButton(position: PosterPositionResponseDTO) -> some View {
      Button {
         if (position.status != .takenDown) {
            showTakeDownAlert = true
         } else {
            showUndoTakeDownAlert = true
         }
      } label: {
         Text(position.status != .takenDown ? "Abhängen bestätigen" : "Abhängen zurückziehen")
            .foregroundStyle(position.status != .takenDown ? Color(UIColor.systemBackground) : Color.red)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
      }
      .background(position.status != .takenDown ? Color.red : Color.gray.opacity(0.2))
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
                     isLoading = true
                     if let image = viewModel.positionImageData {
                        do {
                           try await viewModel.takeDownPosition(image: image)
                        } catch {
                           print("Error taking down position: \(error)")
                        }
                        await viewModel.fetchPosition()
                        viewModel.fetchPositionImage(for: position.id)
                        isLoading = false
                     }
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
                     isLoading = true
                     if let image = viewModel.positionImageData {
                        do {
                           try await viewModel.hangPosition(image: image, latitude: nil, longitude: nil) //Koordinaten ergänzen
                        } catch {
                           print("Error hanging position after taking it down: \(error)")
                        }
                        await viewModel.fetchPosition()
                        viewModel.fetchPositionImage(for: position.id)
                        isLoading = false
                     }
                  }
               },
               secondaryButton: .cancel(Text("Nein"))
            )
         } else {
            return Alert(title: Text("Unknown Action")) // Fallback case
         }
      }
   }
   
   // MARK: - Helper Methods
   // returns a formatted address string
   private func formattedShareText() -> String {
      if let address = viewModel.address {
         return
      """
      \(address)
      """
      }
      return ""
   }
   
   // Checks if the current user is responsible for the position
   func isResponsible() -> Bool {
      guard let myId = myId else { return false }
      return viewModel.position?.responsibleUsers.contains(where: {
         $0.id == myId
      }) ?? false
   }
   
   // Handles updating the position with an image
   private func handleImageUpdate(positionId: UUID, image: Data, coordinates: CLLocationCoordinate2D) async {
        isLoading = true
        do {
           try await viewModel.hangPosition(image: image, latitude: coordinates.latitude, longitude: coordinates.longitude)
        } catch {
           print("Error hanging position: \(error)")
        }
        await viewModel.fetchPosition()
        viewModel.fetchPositionImage(for: positionId)
        isLoading = false
     }
   
   // Loads the user ID of the currently logged-in user
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
}
