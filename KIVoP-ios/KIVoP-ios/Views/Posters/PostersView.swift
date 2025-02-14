// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//
//  PostersView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 09.12.24.
//

// This file defines the view that displays a list of all posters
// It includes fetching posters and images, displays summary information of posters (filtered by active or archived posters), handles navigation

import SwiftUI
import PosterServiceDTOs

struct PostersView: View {
   @Environment(\.dismiss) var dismiss
   @Environment(\.colorScheme) var colorScheme

   @StateObject private var viewModel = PostersViewModel() /// ViewModel responsible for managing poster data
   @State private var postersFiltered: [FilteredPoster] = [] // filtered FilteredPosters, based on searchText
   @State private var selectedPoster: PosterResponseDTO? // selected poster to navigate to
   @State private var isShowingDetails: Bool = false // for navigating to Posters-PosterDetailView
   // viewModel status
   @State private var isLoading = false
   @State private var error: String?
   // text inside the searchbar
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
                         ZStack {
                            if let uiImage = viewModel.posterImages[item.poster.id] {
                               Image(uiImage: uiImage)
                                  .resizable()
                                  .aspectRatio(contentMode: .fit)
                                  .frame(width: 45, height: 45)
                                  .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                                  .background(RoundedRectangle(cornerRadius: 5).fill(Color(uiImage.averageColor ?? .gray)))
                            } else {
                               ProgressView()
                                  .frame(width: 45, height: 45)
                                  .background(.gray.opacity(0.2))
                                  .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                            }
                         }
                         .onAppear() {
                            // loads the image of the poster asynchronous
                            if viewModel.posterImages[item.poster.id] == nil {
                               viewModel.fetchPosterImage(for: item.poster.id)
                            }
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
                // pull-to-refresh
                .refreshable {
                   Task {
                      await viewModel.fetchPosters()
                      postersFiltered = viewModel.filteredPosters
                   }
                }
                // navigate to PosterDetailView of selectedPoster
                .navigationDestination(isPresented: $isShowingDetails) {
                   if let poster = selectedPoster {
                      Posters_PosterDetailView(posterId: poster.id)
                         .navigationTitle(poster.name)
                    }
                }
                
                // Picker for active and archived posters
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
          // fetch posters on appear
          .onAppear {
             Task {
                isLoading = true
                await viewModel.fetchPosters()
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
       // searchbar: search poster names for searchText
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

// extension to get the averageColor of an UIImage (for the background of the poster images)
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
