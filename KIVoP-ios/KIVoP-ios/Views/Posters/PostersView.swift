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
   
   func getDateColor(overdueCount: Int, date: Date) -> Color {
      if overdueCount > 0 {
         return .red
      } else {
         if date < Calendar.current.date(byAdding: .day, value: 1, to: Date())! {
            return .orange
         } else {
            return Color(UIColor.secondaryLabel)
         }
      }
    }
   
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
                            if item.posterSummary.nextTakeDown != nil {
                               Text("\(DateTimeFormatter.formatDate(item.posterSummary.nextTakeDown ?? Date()))")
                                  .frame(maxWidth: .infinity, alignment: .leading)
                                  .font(.callout)
                                  .foregroundStyle(getDateColor(overdueCount: item.posterSummary.overdue, date: item.posterSummary.nextTakeDown ?? Date()))
                            }
                         }
                         
                         Spacer()
                         
                         if (item.posterSummary.toHang > 0) {
                            if item.posterSummary.toHang > 99 {
                               Capsule()
                                  .fill(.blue)
                                  .overlay(
                                    Text("\(item.posterSummary.toHang)")
                                       .font(.system(size: 12))
                                       .frame(width: 22)
                                       .fontWeight(.semibold)
                                       .foregroundStyle(colorScheme == .dark ? .black : .white)
                                       .padding(4)
                                  )
                                  .frame(width: 28, height: 22)
                            } else if item.posterSummary.toHang > 50 {
                               Capsule()
                                  .fill(.blue)
                                  .overlay(
                                    Text("\(item.posterSummary.toHang)")
                                       .font(.system(size: 12))
                                       .frame(width: 20)
                                       .fontWeight(.semibold)
                                       .foregroundStyle(colorScheme == .dark ? .black : .white)
                                       .padding(4)
                                  )
                                  .frame(width: 22, height: 22)
                            } else {
                               Image(systemName: "\(item.posterSummary.toHang).circle.fill")
                                  .resizable()
                                  .frame(maxWidth: 22, maxHeight: 22)
                                  .aspectRatio(1, contentMode: .fit)
                                  .foregroundStyle(.blue)
                                  .padding(.trailing, 5)
                            }
                         }
                         if(item.posterSummary.overdue > 0){
                            if item.posterSummary.overdue > 99 {
                               Capsule()
                                  .fill(.red)
                                  .overlay(
                                    Text("\(item.posterSummary.overdue)")
                                       .font(.system(size: 12))
                                       .frame(width: 22)
                                       .fontWeight(.semibold)
                                       .foregroundStyle(colorScheme == .dark ? .black : .white)
                                       .padding(4)
                                  )
                                  .frame(width: 28, height: 22)
                            } else if item.posterSummary.overdue > 50 {
                               Capsule()
                                  .fill(.red)
                                  .overlay(
                                    Text("\(item.posterSummary.overdue)")
                                       .font(.system(size: 12))
                                       .frame(width: 20)
                                       .fontWeight(.semibold)
                                       .foregroundStyle(colorScheme == .dark ? .black : .white)
                                       .padding(4)
                                  )
                                  .frame(width: 22, height: 22)
                            } else {
                               Image(systemName: "\(item.posterSummary.overdue).circle.fill")
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

#Preview {
    PostersView()
}
