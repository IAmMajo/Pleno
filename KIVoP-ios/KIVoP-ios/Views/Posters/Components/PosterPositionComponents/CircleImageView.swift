// This file is licensed under the MIT-0 License.
//
//  CircleImageView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 11.12.24.
//

import SwiftUI
import MapKit
import AVFoundation
import Photos
import PosterServiceDTOs

// A circular image view that displays a poster position's image
// It allows users to confirm poster placement or report damage via camera interaction
struct CircleImageView: View {
   let position: PosterPositionResponseDTO
   let positionImage: UIImage?
   let isResponsible: Bool
   @Binding var currentCoordinates: CLLocationCoordinate2D?
   var onUpdate: (Data, CLLocationCoordinate2D) -> Void
   
   @State private var selectedImage: UIImage? = nil
   @StateObject private var locationManager = LocationManager()
   
   @State private var showImage: Bool = false
   @State private var showAlert: Bool = false
   @State private var showCamera: Bool = false
   @State private var showPhotoAlert: Bool = false
   @State private var showPhotoPicker = false
   
   @Environment(\.colorScheme) var colorScheme
   
   var body: some View {
      VStack {
         // MARK: - Displaying the Image Based on Poster Status
         // displaying image when the position is still to hang
         if position.status == .toHang {
            if let selectedImage{
               // If the user has selected an image, display it
               Image(uiImage: selectedImage)
                  .resizable()
                  .scaledToFill()
                  .frame(width: 165, height: 165)
                  .clipShape(Circle())
                  .shadow(radius: 5)
                  .onTapGesture {
                     showImage = true
                  }
                  .navigationDestination(isPresented: $showImage) {
                     FullImageView(uiImage: selectedImage)
                  }
            } else {
               // Display a placeholder indicating that the responsible user needs to upload an image
               Rectangle()
                  .fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
                  .frame(width: 165, height: 165)
                  .overlay(
                     // if the user is responsible indicate the user needs to upload an image, else display placeholder
                     VStack {
                        if isResponsible {
                           Image(systemName: "camera.fill")
                              .foregroundStyle(.gray)
                              .font(.system(size: 50))
                              .padding(.bottom, 2)
                           Text("Aufhängen\nbestätigen")
                              .font(.callout)
                              .fontWeight(.semibold)
                              .foregroundStyle(.gray)
                        }else {
                           Image(systemName: "photo")
                              .foregroundStyle(.gray)
                              .font(.system(size: 75))
                              .padding(.bottom, 2)
                        }
                     }
                  )
                  .cornerRadius(500)
                  .shadow(radius: 5)
                  .onTapGesture {
                     // if user is responsible and wants to upload an image, show alert with directions
                     if isResponsible {
                        showAlert = true
                     }
                  }
                  .alert("Alles im Blick?", isPresented: $showAlert) {
                     Button("Verstanden") {
                        // tracks the user's location and shows the camera
                        handleLocationAndShowCamera()
                     }
                  } message: {
                     Text("Achte beim Aufnehmen des Bildes darauf, dass das Plakat sowie der Hintergrund und die Umgebung gut zu erkennen sind.")
                  }
               // opens camera as fullScreenCover
                  .fullScreenCover(isPresented: $showCamera) {
                     accessCameraView(
                        isDamageReport: false, // user hangs a position, not reporting damage
                        selectedImage: $selectedImage,
                        showCamera: $showCamera,
                        currentCoordinates: $currentCoordinates
                     ) {
                        // get taken image and location data for hanging the poster position, and pass it to the Posters-PositionView
                        if let image = selectedImage,
                           let imageData = image.jpegData(compressionQuality: 0.8),
                           let coordinates = currentCoordinates {
                           onUpdate(imageData, coordinates)
                        }
                     }
                     .background(.black)
                  }
            }
            // displaying an image when the position is damaged
         } else if position.status == .damaged {
            if let uiImage = positionImage {
               // position image
               Image(uiImage: uiImage)
                  .resizable()
                  .scaledToFill()
                  .frame(width: 165, height: 165)
                  .clipShape(Circle())
                  .shadow(radius: 5)
                  .onTapGesture {
                     showImage = true
                  }
                  .navigationDestination(isPresented: $showImage) {
                     FullImageView(uiImage: uiImage)
                  }
               // if the user is responsible display an overlay to confirm that the position got fixed
                  .overlay(alignment: .bottom) {
                     if isResponsible {
                        VStack(spacing: 2) {
                           Text("Beschädigung")
                           HStack {
                              Text("behoben")
                              Image(systemName: "camera.fill")
                           }
                        }
                        .frame(width: 165, height: 35)
                        .padding(8) .padding(.bottom, 15)
                        .foregroundStyle(.white)
                        .background(.black.opacity(0.5))
                        // if user is responsible and wants to upload an image, show alert with directions
                        .onTapGesture {
                           if isResponsible {
                              showAlert = true
                           }
                        }
                        .alert("Alles im Blick?", isPresented: $showAlert) {
                           Button("Verstanden") {
                              handleLocationAndShowCamera()
                           }
                        } message: {
                           Text("Achte beim Aufnehmen des Bildes darauf, dass das Plakat sowie der Hintergrund und die Umgebung gut zu erkennen sind.")
                        }
                        // opens camera as fullScreenCover
                        .fullScreenCover(isPresented: $showCamera) {
                           accessCameraView(
                              isDamageReport: false, // user re-hangs a fixed position, not reporting damage
                              selectedImage: $selectedImage,
                              showCamera: $showCamera,
                              currentCoordinates: $currentCoordinates
                           ) {
                              // get taken image and location data for re-hanging the poster position, and pass it to the Posters-PositionView
                              if let image = selectedImage,
                                 let imageData = image.jpegData(compressionQuality: 0.8),
                                 let coordinates = currentCoordinates {
                                 onUpdate(imageData, coordinates)
                              }
                           }
                           .background(.black)
                        }
                     }
                  }
                  .mask(Circle())
            } else {
               // display ProgressView when the image is still loading
               ProgressView()
                  .frame(width: 165, height: 165)
                  .background(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
                  .clipShape(Circle())
            }
            // when position hangs and isn't damaged just display the image
         } else {
            if let uiImage = positionImage {
               Image(uiImage: uiImage)
                  .resizable()
                  .scaledToFill()
                  .frame(width: 165, height: 165)
                  .clipShape(Circle())
                  .shadow(radius: 5)
                  .onTapGesture {
                     showImage = true
                  }
                  .navigationDestination(isPresented: $showImage) {
                     FullImageView(uiImage: uiImage)
                  }
            } else {
               // display ProgressView when the image is still loading
               ProgressView()
                  .frame(width: 165, height: 165)
                  .background(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
                  .clipShape(Circle())
            }
         }
      }
   }
   
   // MARK: - Location handeling and accessing the camera
   
   /// Handles location tracking and opens the camera for capturing an image
   private func handleLocationAndShowCamera() {
      locationManager.startUpdatingLocation() // Starts fetching the user's current location
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Delay to ensure GPS locks
         if let location = locationManager.location {
            // Saves the fetched location coordinates into `currentCoordinates`
            self.currentCoordinates = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            print("Coordinates: \(location.latitude), \(location.longitude)")
         } else {
            print("No location found.")
         }
         locationManager.stopUpdatingLocation()  // Stops location updates to preserve battery
         self.showCamera.toggle() // Opens the camera view
      }
   }
}

/// Represents a camera view that allows users to capture images
struct accessCameraView: UIViewControllerRepresentable {
   let isDamageReport: Bool // Indicates if the image is for reporting damage or confirming placement
   @Binding var selectedImage: UIImage? // Stores the captured image
   @Binding var showCamera: Bool // Controls whether the camera view is displayed
   @Binding var currentCoordinates: CLLocationCoordinate2D? // Stores the coordinates when capturing an image
   var onPhotoPicked: () -> Void // Closure to notify when photo is picked
   @Environment(\.presentationMode) var isPresented
   
   /// Creates and configures a `UIImagePickerController` for capturing photos
   func makeUIViewController(context: Context) -> UIImagePickerController {
      let imagePicker = UIImagePickerController()
      imagePicker.sourceType = .camera
      imagePicker.allowsEditing = false
      imagePicker.delegate = context.coordinator
      return imagePicker
   }
   
   /// Updates the camera view controller
   func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
      
   }
   
   /// Creates and returns a `Coordinator` to handle image selection
   func makeCoordinator() -> Coordinator {
      return Coordinator(picker: self)
   }
   
   /// Updates the location when reopening the camera
   func updateLocationForCameraReset() {
      let locationManager = LocationManager()
      
      locationManager.startUpdatingLocation()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Delay to ensure GPS locks
         if let location = locationManager.location {
            self.currentCoordinates = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            print("New Coordinates: \(location.latitude), \(location.longitude)")
         } else {
            print("No location found.")
         }
         locationManager.stopUpdatingLocation()
      }
   }
}

// MARK: - Coordinator for Handling Image Selection
/// A helper class that acts as a delegate for `UIImagePickerController`
/// Handles image selection and confirmation alerts
class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
   var picker: accessCameraView // Reference to the `accessCameraView` instance
   
   init(picker: accessCameraView) {
      self.picker = picker
   }
   
   /// Called when the user selects or captures an image
   func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      // Extracts the selected image from the provided `info` dictionary
      guard let selectedImage = info[.originalImage] as? UIImage else { return }
      
      // Presents an alert asking the user to confirm or retake the photo
      let alertController = UIAlertController(
         title: NSLocalizedString("Passt alles?", comment: ""),
         message: self.picker.isDamageReport
         ? NSLocalizedString("Ist das beschädigte, oder fehlende Plakat und seine Umgebung gut zu erkennen und das Bild nicht verwackelt?", comment: "") // Message for damage reports
         : NSLocalizedString("Achtung, du kannst das Bild später nicht mehr ändern. Ist das Plakat und seine Umgebung gut zu erkennen und das Bild nicht verwackelt?", comment: ""), // Message for confirmation of a new placement
         preferredStyle: .alert
      )
      
      // User confirms that the image is correct
      alertController.addAction(UIAlertAction(title: NSLocalizedString("Passt", comment: ""), style: .default, handler: { _ in
         // Save the selected image
         self.picker.selectedImage = selectedImage
         // Notify SwiftUI view that the photo was picked
         self.picker.onPhotoPicked()
         picker.dismiss(animated: true) // Dismiss the camera
      }))
      
      // User wants to retake the picture
      alertController.addAction(UIAlertAction(title: NSLocalizedString("Erneut aufnehmen", comment: ""), style: .cancel, handler: { _ in
         if !self.picker.isDamageReport {
            // Update location before retaking the image
            self.picker.updateLocationForCameraReset()
         }
         picker.dismiss(animated: true) { // dismiss camera
            self.picker.$showCamera.wrappedValue = false
            self.picker.$showCamera.wrappedValue = true // open camera
         }
      }))
      
      // Present the alert over the camera view
      picker.present(alertController, animated: true, completion: nil)
   }
}

// MARK: - CLLocationCoordinate2D Extension
/// Extends `CLLocationCoordinate2D` to conform to `Equatable`, allowing easy comparison of coordinates.
extension CLLocationCoordinate2D: @retroactive Equatable {
   public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
      lhs.latitude == rhs.latitude &&
      lhs.longitude == rhs.longitude
   }
}

