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
   let earliestPosition: PosterPositionResponseDTO
   let tohangCount: Int
   let expiredCount: Int
   
   static func == (lhs: FilteredPoster, rhs: FilteredPoster) -> Bool {
      return lhs.poster.id == rhs.poster.id &&
      lhs.earliestPosition.id == rhs.earliestPosition.id &&
      lhs.tohangCount == rhs.tohangCount &&
      lhs.expiredCount == rhs.expiredCount
   }
}

struct PostersView: View {
   @Environment(\.dismiss) var dismiss
   @Environment(\.colorScheme) var colorScheme

   @StateObject private var viewModel = PostersViewModel()
   @State private var postersFiltered: [FilteredPoster] = []
   @State private var selectedPoster: PosterResponseDTO?
   @State private var isShowingDetails: Bool = false
   @State private var isLoading = false
   @State private var error: String?
   
   @State private var searchText = ""
   
   
    var body: some View {
       VStack {
//          if isLoading {
//             ProgressView("Loading...")
//          } else if let error = error {
//             Text("Error: \(error)")
//                .foregroundColor(.red)
//          }
          ZStack(alignment: .top) {
             if !viewModel.posters.isEmpty {
                List {
                   ForEach(postersFiltered, id: \.poster.id) { item in
                      HStack {
                         if let uiImage = UIImage(data: item.poster.image) {
                            if let averageUIColor = uiImage.averageColor {
                               let averageColor = Color(averageUIColor)
                               RoundedRectangle(cornerRadius: 5, style: .continuous)
                                  .fill(averageColor)
                                  .frame(width: 45, height: 45)
                                  .overlay {
                                     Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 45, height: 45)
                                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                                     
                                  }
                            } else {
                               RoundedRectangle(cornerRadius: 5, style: .continuous)
                                  .fill(Color(UIColor.secondarySystemBackground))
                                  .frame(width: 45, height: 45)
                                  .overlay {
                                     Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 45, height: 45)
                                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                                     
                                  }
                            }
                         } else {
                            Image(systemName: "text.rectangle.page.fill")
                               .resizable()
                               .frame(maxWidth: 45, maxHeight: 45)
                               .aspectRatio(1, contentMode: .fit)
                               .foregroundStyle(.gray.opacity(0.5))
                               .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                               .padding(.trailing, 5)
                         }
                         
                         VStack {
                            Text(item.poster.name)
                               .frame(maxWidth: .infinity, alignment: .leading)
                            //
                            Text("\(DateTimeFormatter.formatDate(item.earliestPosition.expiresAt))")
                               .frame(maxWidth: .infinity, alignment: .leading)
                               .font(.callout)
                               .foregroundStyle(DateColorHelper.getDateColor(position: item.earliestPosition))
                            
                         }
                         
                         Spacer()
                         
                         //damaged count hinzufügen?
                         if (item.tohangCount != 0) {
                            if item.tohangCount > 99 {
                               Capsule()
                                  .fill(.blue)
                                  .overlay(
                                    Text("\(item.tohangCount)")
                                       .font(.system(size: 12))
                                       .frame(width: 22)
                                       .fontWeight(.semibold)
                                       .foregroundStyle(colorScheme == .dark ? .black : .white)
                                       .padding(4)
                                  )
                                  .frame(width: 28, height: 22)
                            } else if item.tohangCount > 50 {
                               Capsule()
                                  .fill(.blue)
                                  .overlay(
                                    Text("\(item.tohangCount)")
                                       .font(.system(size: 12))
                                       .frame(width: 20)
                                       .fontWeight(.semibold)
                                       .foregroundStyle(colorScheme == .dark ? .black : .white)
                                       .padding(4)
                                  )
                                  .frame(width: 22, height: 22)
                            } else {
                               Image(systemName: "\(item.tohangCount).circle.fill")
                                  .resizable()
                                  .frame(maxWidth: 22, maxHeight: 22)
                                  .aspectRatio(1, contentMode: .fit)
                                  .foregroundStyle(.blue)
                                  .padding(.trailing, 5)
                            }
                         }
                         if(item.expiredCount > 0){
                            if item.expiredCount > 99 {
                               Capsule()
                                  .fill(.red)
                                  .overlay(
                                    Text("\(item.expiredCount)")
                                       .font(.system(size: 12))
                                       .frame(width: 22)
                                       .fontWeight(.semibold)
                                       .foregroundStyle(colorScheme == .dark ? .black : .white)
                                       .padding(4)
                                  )
                                  .frame(width: 28, height: 22)
                            } else if item.expiredCount > 50 {
                               Capsule()
                                  .fill(.red)
                                  .overlay(
                                    Text("\(item.expiredCount)")
                                       .font(.system(size: 12))
                                       .frame(width: 20)
                                       .fontWeight(.semibold)
                                       .foregroundStyle(colorScheme == .dark ? .black : .white)
                                       .padding(4)
                                  )
                                  .frame(width: 22, height: 22)
                            } else {
                               Image(systemName: "\(item.expiredCount).circle.fill")
                                  .resizable()
                                  .frame(maxWidth: 22, maxHeight: 22)
                                  .aspectRatio(1, contentMode: .fit)
                                  .foregroundStyle(.red)
                                  .padding(.trailing, 5)
                            }
                         }
                         
                         Spacer()
                      }
                      .contentShape(Rectangle())
                      .onTapGesture {
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
                .navigationDestination(isPresented: $isShowingDetails) {
                   if let poster = selectedPoster {
                      Posters_PosterDetailView(posterId: poster.id)
                         .navigationTitle(poster.name)
                    }
                }
                
                Picker("Filter", selection: $viewModel.selectedTab) {
                    Text("Aktuell").tag(0)
                    Text("Archiviert").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal) .padding(.bottom, 10) .padding(.top, 1)
                .background(Color(UIColor.systemBackground))
                
//             } else if isLoading {
//                ProgressView("Loading...")
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
                postersFiltered = viewModel.filteredPosters
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

#Preview {
    PostersView()
}
