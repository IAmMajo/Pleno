//
//  PostersView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 09.12.24.
//

import SwiftUI
import PosterServiceDTOs

struct FilteredPoster: Equatable {
   let poster: PosterResponseDTO
   let nextTakeDownPosition: PosterPositionResponseDTO
   let tohangCount: Int
   let expiredCount: Int
   
   static func == (lhs: FilteredPoster, rhs: FilteredPoster) -> Bool {
      return lhs.poster.id == rhs.poster.id &&
      lhs.nextTakeDownPosition.id == rhs.nextTakeDownPosition.id &&
      lhs.tohangCount == rhs.tohangCount &&
      lhs.expiredCount == rhs.expiredCount
   }
}

struct FilteredPoster2: Equatable {
   let poster: PosterResponseDTO
   let posterSummary: PosterSummaryResponseDTO
   
   static func == (lhs: FilteredPoster2, rhs: FilteredPoster2) -> Bool {
      return lhs.poster.id == rhs.poster.id
   }
}

struct PostersView: View {
   @Environment(\.dismiss) var dismiss
   @Environment(\.colorScheme) var colorScheme

   @StateObject private var viewModel = PostersViewModel()
   @State private var postersFiltered: [FilteredPoster2] = []
   @State private var selectedPoster: PosterResponseDTO?
   @State private var isShowingDetails: Bool = false
   @State private var isLoading = false
   @State private var error: String?
   
   @State private var searchText = ""
   
   // Determines color for next-take-down date of the poster
   private func getDateColor(overdueCount: Int, date: Date) -> Color {
      if overdueCount > 0 { // if there are overdue positions -> the date must belong to one of these
         return .red
      } else if date < Calendar.current.date(byAdding: .day, value: 1, to: Date())! { // the date will be overdue in less than a day
         return .orange
      }
      return Color(UIColor.secondaryLabel)
   }
   
   // Renders a badge for toHang or overdue counts
   private func badgeView(count: Int, color: Color) -> some View {
      if count > 0 {
         return AnyView(
            Capsule()
               .fill(color)
               .overlay(
                  Text("\(count)")
                     .font(.system(size: count > 99 ? 12 : 14))
                     .fontWeight(.semibold)
                     .frame(width: count > 99 ? 28 : 22, height: 22)
                     .foregroundStyle(colorScheme == .dark ? .black : .white)
                     .padding(4)
               )
               .frame(width: count > 99 ? 28 : 22, height: 22)
         )
      }
      return AnyView(EmptyView())
   }
   
    var body: some View {
       VStack {
          ZStack(alignment: .top) {
             if !viewModel.posters.isEmpty {
                // List of posters
                List {
                   ForEach(postersFiltered, id: \.poster.id) { item in
                      HStack {
                         // Poster image
                         if let uiImage = UIImage(data: item.poster.image) {
                            Image(uiImage: uiImage)
                               .resizable()
                               .aspectRatio(contentMode: .fit)
                               .frame(width: 45, height: 45)
                               .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                               .background(RoundedRectangle(cornerRadius: 5).fill(Color(uiImage.averageColor ?? .gray)))
                         } else {
                            Image(systemName: "text.rectangle.page.fill")
                               .resizable()
                               .frame(maxWidth: 45, maxHeight: 45)
                               .aspectRatio(1, contentMode: .fit)
                               .foregroundStyle(.gray.opacity(0.5))
                               .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                               .padding(.trailing, 5)
                         }
                         
                         // Poster details
                         VStack {
                            Text(item.poster.name)
                               .frame(maxWidth: .infinity, alignment: .leading)
                            // nextTakeDown date of the poster
                            if let nextTakeDown = item.posterSummary.nextTakeDown {
                               Text("\(DateTimeFormatter.formatDate(nextTakeDown))")
                                  .frame(maxWidth: .infinity, alignment: .leading)
                                  .font(.callout)
                                  .foregroundStyle(getDateColor(overdueCount: item.posterSummary.overdue, date: nextTakeDown))
                            }
                         }
                         
                         Spacer()
                         
                         // Display badges for toHang and overdue counts
                         HStack(spacing: 10) {
                            badgeView(count: item.posterSummary.toHang, color: .blue)
                            badgeView(count: item.posterSummary.overdue, color: .red)
                         }
                      }
                      .contentShape(Rectangle()) // makes the HStack clickable
                      .onTapGesture { // on tap: navigate to PosterDetailView of selectedPoster
                         selectedPoster = item.poster
                         isShowingDetails = true
                      }
                   }
                }
                .padding(.top, 20)
                .refreshable {
                   Task {
                      await viewModel.fetchPosters()
                      postersFiltered = viewModel.filteredPosters
                   }
                }
                .navigationDestination(isPresented: $isShowingDetails) { // navigate to PosterDetailView of selectedPoster
                   if let poster = selectedPoster {
                      Posters_PosterDetailView(posterId: poster.id)
                         .navigationTitle(poster.name)
                    }
                }
                
                // Picker for current and archived posters
                Picker("Filter", selection: $viewModel.selectedTab) {
                    Text("Aktuell").tag(0)
                    Text("Archiviert").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal) .padding(.bottom, 10) .padding(.top, 1)
                .background(Color(UIColor.systemBackground))

             } else {
                ContentUnavailableView {
                   if let error = error {
                      Text("Error: \(error)").foregroundColor(.red)
                   }
                }
             }
             
          }
          .navigationTitle("Plakate")
          .navigationBarTitleDisplayMode(.inline)
          .onAppear {
             Task {
                isLoading = true
                await viewModel.fetchPosters()
//                postersFiltered = viewModel.filteredPosters
                isLoading = false
             }
          }
          .overlay {
             if isLoading {
                ProgressView("Loading...")
             } else if let error = error {
                Text("Error: \(error)")
                   .foregroundColor(.red)
             }
          }
          
       }
       .background(Color(UIColor.secondarySystemBackground))
       .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Suchen")
       .onChange(of: viewModel.filteredPosters) { old, newFilteredPosters in
          postersFiltered = newFilteredPosters
       }
       .onChange(of: searchText) {
          Task {
             if searchText.isEmpty {
                postersFiltered = viewModel.filteredPosters
             } else {
                postersFiltered = viewModel.filteredPosters.filter { item in
                   return item.poster.name.localizedCaseInsensitiveContains(searchText)
                }
             }
          }
       }
    }
}

extension UIImage {
   var averageColor: UIColor? {
      guard let inputImage = CIImage(image: self) else { return nil }
      let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
      
      guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
      guard let outputImage = filter.outputImage else { return nil }
      
      var bitmap = [UInt8](repeating: 0, count: 4)
      let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
      context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
      
      return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
   }
}

#Preview {
    PostersView()
}
