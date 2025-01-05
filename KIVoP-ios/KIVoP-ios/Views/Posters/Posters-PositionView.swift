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
//import CoreHaptics

struct Posters_PositionView: View {
   let position: PosterPosition
   @State var name: String = "Am Grabstein 6"
   @State var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 51.500603516488205, longitude: 6.545327532716446)
   @State private var currentCoordinates: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 51.500603516488205, longitude: 6.545327532716446)
   
   @State private var address: String?
   @State private var isLoadingAddress = true
   
   @State private var isFullMapView: Bool = false
   @State private var showMapOptions: Bool = false
   @State private var shareLocation = false
   @State private var showTakeDownAlert = false
   @State private var showUndoTakeDownAlert = false
   @State private var copiedToClipboard: Bool = false
   @State private var tappedCopyButton: Bool = false
   @FocusState private var isFocused: Bool
   @State private var text = "Sample text"
   @Environment(\.dismiss) private var dismiss
   @Environment(\.colorScheme) var colorScheme
   
   func getDateColor(status: Status) -> Color {
      switch status {
      case .hung:
         return Color(UIColor.label).opacity(0.75)
      case .takenDown:
         return Color(UIColor.label).opacity(0.75)
      case .notDisplayed:
         return Color(UIColor.label).opacity(0.75)
      case .expiresInOneDay:
         return .orange
      case .expired:
         return .red
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
            self.name = placemark.name ?? "Name"
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
   
    var body: some View {
       VStack {
          ScrollView {
             VStack {
                MapView(name: name, coordinate: currentCoordinates!)
                   .frame(height: 250)
                   .onTapGesture {
//                      showMapOptions = true
                      isFullMapView = true
                   }
                   .navigationDestination(isPresented: $isFullMapView) { FullMapView(address: address ?? "", name: name, coordinate: currentCoordinates ?? CLLocationCoordinate2D(latitude: 51.500603516488205, longitude: 6.545327532716446))}
                
                CircleImageView(status: position.status, currentCoordinates: $currentCoordinates)
                //                   .offset(y: -47)
                   .padding(.top, -95)
                   .shadow(radius: 5)
                
                HStack {
                   Text("Abhängedatum:")
                      .foregroundStyle(Color(UIColor.label).opacity(0.75))
                      .fontWeight(.semibold)
                      .padding(.trailing, -2)
                   
                   Text("\(DateTimeFormatter.formatDate(position.expiresAt))")
                      .fontWeight(.semibold)
                      .foregroundStyle(getDateColor(status: position.status))
                }.padding(.top, 10)
                
                VStack{
                   ProgressInfoView(status: position.status)
                      .padding(.leading) .padding(.trailing)
                      .padding(.top, 8) .padding(.bottom, 8)
                   
                   ProgressBarView(status: position.status)
                      .padding(.leading) .padding(.trailing)
                   if position.status == .notDisplayed {
                      Text("Mache jetzt ein Foto des aufgehängten Plakats und bestätige die Position")
                         .font(.system(size: 10))
                         .foregroundStyle(.secondary)
                   }
                }
                
                var mockUsers: [GetIdentityDTO] {
                   [mockIdentity1, mockIdentity2]
                }
                List{
                   Section {
                      //                      var mockUsers: [GetIdentityDTO] {
                      //                         [mockIdentity1, mockIdentity2]
                      //                      }
                      //                      position.responsibleUserIds
                      ForEach (mockUsers, id: \.self) { user in
                         HStack {
                            Image(systemName: "person.crop.square.fill")
                               .resizable()
                               .frame(maxWidth: 40, maxHeight: 40)
                               .aspectRatio(1, contentMode: .fit)
                               .foregroundStyle(.gray.opacity(0.5))
                               .padding(.trailing, 5)
                            
                            Text(user.name)
                         }
                      }
                   } header: {
                      Text("Verantwortliche (2)")
                   }
                }
                .scrollDisabled(true)
                .frame(height: CGFloat((mockUsers.count * 15) + (mockUsers.count < 4 ? 130 : 0)), alignment: .top)
                //             .scrollContentBackground(.hidden)
                .environment(\.defaultMinListHeaderHeight, 10)
                
                Form {
                   Section {
                      HStack(spacing: 0) {
                         Text(address ?? "")
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
                      HStack {
                         Text("\(String(format: "%.6f", currentCoordinates!.latitude))° N, \(String(format: "%.6f", currentCoordinates!.longitude))° E")
                            .textSelection(.enabled)
                         
                         Spacer()
                         
                         Button(action: {
                            tappedCopyButton.toggle()
                            UIPasteboard.general.string = "\(String(format: "%.6f", currentCoordinates!.latitude))° N, \(String(format: "%.6f", currentCoordinates!.longitude))° E"
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
                   } header: {
                      Text("Adresse in der Nähe")
                   }
                }
                .scrollDisabled(true)
                .frame(height: 185)
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
             .confirmationDialog("\(address ?? "Adresse")\n\(currentCoordinates!.latitude), \(currentCoordinates!.longitude)", isPresented: $showMapOptions, titleVisibility: .visible) {
                Button("Öffnen mit Apple Maps") {
                   openInAppleMaps()
                }
                Button("Öffnen mit Google Maps") {
                   openInGoogleMaps()
                }
                Button("Öffnen mit Waze") {
                   openInWaze()
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
          }
          if (position.status != Status.notDisplayed) {
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
                           // Perform "Plakat abhängen" action here
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
                        }
                     },
                     secondaryButton: .cancel(Text("Nein"))
                   )
                } else {
                   return Alert(title: Text("Unknown Action")) // Fallback case
                }
             }
          }
       }
       .navigationBarTitleDisplayMode(.inline)
       .background(colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground))
       .onAppear {
          fetchAddress(latitude: currentCoordinates!.latitude, longitude: currentCoordinates!.longitude)
          Task {
             
          }
       }
       .onChange(of: currentCoordinates) { oldValue, newValue in
          fetchAddress(latitude: currentCoordinates!.latitude, longitude: currentCoordinates!.longitude)
       }
    }
   
   private func openInAppleMaps() {
      let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: currentCoordinates!))
      mapItem.name = name
      mapItem.openInMaps()
   }
   
   private func openInGoogleMaps() {
      let urlString = "comgooglemaps://?q=\(currentCoordinates!.latitude),\(currentCoordinates!.longitude)"
      if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
         UIApplication.shared.open(url)
      } else {
         // Fallback to Google Maps in browser if the app is not installed
         if let webUrl = URL(string: "https://www.google.com/maps?q=\(currentCoordinates!.latitude),\(currentCoordinates!.longitude)") {
            UIApplication.shared.open(webUrl)
         }
      }
   }
   
   private func openInWaze() {
      let urlString = "waze://?ll=\(currentCoordinates!.latitude),\(currentCoordinates!.longitude)&navigate=yes"
      if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
         UIApplication.shared.open(url)
      } else {
         // Fallback to Waze in browser if the app is not installed
         if let webUrl = URL(string: "https://www.waze.com/ul?ll=\(currentCoordinates!.latitude),\(currentCoordinates!.longitude)&navigate=yes") {
            UIApplication.shared.open(webUrl)
         }
      }
   }
   
   private func formattedShareText() -> String {
//      """
//      \(address ?? "")
//      \(coordinate.latitude), \(coordinate.longitude)
//      """
      """
      \(address ?? "")
      """
   }
}

#Preview {
   Posters_PositionView(position: mockPosterPosition1)
}
