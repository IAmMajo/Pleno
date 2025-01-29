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

struct CircleImageView: View {
   let position: PosterPositionResponseDTO
   let isResponsible: Bool
   @Binding var currentCoordinates: CLLocationCoordinate2D?
   @State private var selectedImage: UIImage? = nil
   var onUpdate: (Data, CLLocationCoordinate2D) -> Void
   
   @StateObject private var locationManager = LocationManager()
   
   @State private var showImage: Bool = false
   @State private var showAlert: Bool = false
   @State private var showCamera: Bool = false
   @State private var showPhotoAlert: Bool = false
   @State private var showPhotoPicker = false
   @Environment(\.colorScheme) var colorScheme
   
   var body: some View {
      VStack {
         if position.status == .toHang {
            if let selectedImage{
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
//                     FullImageView(image: "TestPositionImage") Image(uiImage: uiImage)
                  }
            } else {
               Rectangle()
               //            .fill(Color(UIColor.systemGray4))
                  .fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
                  .frame(width: 165, height: 165)
                  .overlay(
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
                  .fullScreenCover(isPresented: $showCamera) {
                     accessCameraView(
                        isDamageReport: false,
                        selectedImage: $selectedImage,
                        showCamera: $showCamera,
                        currentCoordinates: $currentCoordinates
                     ) {
                        if let image = selectedImage,
                           let imageData = image.jpegData(compressionQuality: 0.8),
                           let coordinates = currentCoordinates {
                           onUpdate(imageData, coordinates)
                        }
                     }
                     .background(.black)
                  }
            }
         } else if position.status == .damaged {
            if let image = position.image {
               let uiImage = UIImage(data: image)
               Image(uiImage: uiImage!)
                  .resizable()
                  .scaledToFill()
                  .frame(width: 165, height: 165)
                  .clipShape(Circle())
                  .shadow(radius: 5)
                  .onTapGesture {
                     showImage = true
                  }
                  .navigationDestination(isPresented: $showImage) {
                     FullImageView(uiImage: uiImage!)
                  }
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
                        .fullScreenCover(isPresented: $showCamera) {
                           accessCameraView(
                              isDamageReport: false,
                              selectedImage: $selectedImage,
                              showCamera: $showCamera,
                              currentCoordinates: $currentCoordinates
                           ) {
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
            }
         } else {
            if let image = position.image {
               let uiImage = UIImage(data: image)
               Image(uiImage: uiImage!)
                  .resizable()
                  .scaledToFill()
                  .frame(width: 165, height: 165)
                  .clipShape(Circle())
                  .shadow(radius: 5)
                  .onTapGesture {
                     showImage = true
                  }
                  .navigationDestination(isPresented: $showImage) {
                     FullImageView(uiImage: uiImage!)
                  }
            }
         }
      }
      .onChange(of: currentCoordinates) { oldCoordinates, newCoordinates in
         if let coordinates = newCoordinates {
            print("Photo coordinates: \(coordinates.latitude), \(coordinates.longitude)")
         } else {
            print("No coordinates found")
         }
      }
   }
   
   private func handleLocationAndShowCamera() {
      locationManager.startUpdatingLocation()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Delay to ensure GPS locks
         if let location = locationManager.location {
            self.currentCoordinates = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            print("Coordinates: \(location.latitude), \(location.longitude)")
         } else {
            print("No location found.")
         }
         locationManager.stopUpdatingLocation()
         self.showCamera.toggle()
      }
   }
}

struct accessCameraView: UIViewControllerRepresentable {
   let isDamageReport: Bool
   @Binding var selectedImage: UIImage?
   @Binding var showCamera: Bool
   @Binding var currentCoordinates: CLLocationCoordinate2D?
   var onPhotoPicked: () -> Void // Closure to notify when photo is picked
   @Environment(\.presentationMode) var isPresented
   
   func makeUIViewController(context: Context) -> UIImagePickerController {
      let imagePicker = UIImagePickerController()
      imagePicker.sourceType = .camera
      imagePicker.allowsEditing = false
      imagePicker.delegate = context.coordinator
      return imagePicker
   }
   
   func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
      
   }
   
   func makeCoordinator() -> Coordinator {
      return Coordinator(picker: self)
   }
   
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

// Coordinator will help to preview the selected image in the View.
class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
   var picker: accessCameraView
   
   init(picker: accessCameraView) {
      self.picker = picker
   }
   
   func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      guard let selectedImage = info[.originalImage] as? UIImage else { return }
      
      // Present the alert over the camera
      let alertController = UIAlertController(
         title: "Passt alles?",
         message: self.picker.isDamageReport ? "Ist das beschädigte, oder fehlende Plakat und seine Umgebung gut zu erkennen und das Bild nicht verwackelt?" : "Achtung, du kannst das Bild später nicht mehr ändern. Ist das Plakat und seine Umgebung gut zu erkennen und das Bild nicht verwackelt?",
         preferredStyle: .alert
      )
      
      alertController.addAction(UIAlertAction(title: "Passt", style: .default, handler: { _ in
         self.picker.selectedImage = selectedImage
         // Notify SwiftUI view that the photo was confirmed
         self.picker.onPhotoPicked()
         picker.dismiss(animated: true) // Dismiss the camera
      }))
      
      alertController.addAction(UIAlertAction(title: "Erneut aufnehmen", style: .cancel, handler: { _ in
         if !self.picker.isDamageReport {
            self.picker.updateLocationForCameraReset()
         }
         picker.dismiss(animated: true) { // dismiss camera
            self.picker.$showCamera.wrappedValue = false
            self.picker.$showCamera.wrappedValue = true // open camera
         }
      }))
      
      picker.present(alertController, animated: true, completion: nil)
   }
}

extension CLLocationCoordinate2D: @retroactive Equatable {
   public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
      lhs.latitude == rhs.latitude &&
      lhs.longitude == rhs.longitude
   }
}

//#Preview {
//   CircleImageView(status: Status.notDisplayed, currentCoordinates: CLLocationCoordinate2D(latitude: 51.500603516488205, longitude: 6.545327532716446))
//}
