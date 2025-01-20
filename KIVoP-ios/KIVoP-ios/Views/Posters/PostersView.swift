//
//  PostersView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 09.12.24.
//

import SwiftUI
import PosterServiceDTOs

struct PostersView: View {
   @Environment(\.dismiss) var dismiss
   
//   @State private var posters: [PosterResponseDTO] = []
//   @State private var postersFiltered: [PosterResponseDTO] = []
   
   @StateObject private var viewModel = PostersViewModel()
   @State private var selectedPoster: PosterResponseDTO?
   @State private var isShowingDetails: Bool = false
   @State private var isLoading = false
   @State private var error: String?
   
   @State private var searchText = ""
   
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
   
   private func base64ToImage(base64String: String) -> UIImage? {
      guard let imageData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) else {
         return nil
      }
      return UIImage(data: imageData)
   }
   
    var body: some View {
       ZStack {
          ZStack(alignment: .top) {
             if !viewModel.posters.isEmpty {
                List {
                   ForEach(viewModel.filteredPosters, id: \.poster.id) { item in
//                      NavigationLink(destination: Posters_PosterDetailView(poster: item.poster).navigationTitle(item.poster.name)) {
                         HStack {
//                            if let image = base64ToImage(base64String: item.poster.imageUrl) {
//                               RoundedRectangle(cornerRadius: 5, style: .continuous)
//                                  .fill(Color(UIColor.secondarySystemBackground))
//                                  .frame(width: 45, height: 45)
//                                  .overlay {
//                                     Image(uiImage: image)
//                                        .resizable()
//                                                                       .scaledToFill()
////                                        .aspectRatio(contentMode: .fit)
//                                        .frame(width: 45, height: 45)
//                                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
//                                        
//                                  }
                            if let uiImage = UIImage(data: item.poster.image) {
                               RoundedRectangle(cornerRadius: 5, style: .continuous)
                                  .fill(Color(UIColor.secondarySystemBackground))
                                  .frame(width: 45, height: 45)
                                  .overlay {
                                     Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
//                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 45, height: 45)
                                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                                        
                                  }
                            }
                            VStack {
                               Text(item.poster.name)
                                  .frame(maxWidth: .infinity, alignment: .leading)
//
                               Text("\(DateTimeFormatter.formatDate(item.earliestPosition.expiresAt))")
                                     .frame(maxWidth: .infinity, alignment: .leading)
                                     .font(.callout)
                                     .foregroundStyle(getDateColor(position: item.earliestPosition))
                               
                            }
                            Spacer()
                            if (item.tohangCount != 0) {
                               Image(systemName: "\(item.tohangCount).circle.fill")
                                  .resizable()
                                  .frame(maxWidth: 22, maxHeight: 22)
                                  .aspectRatio(1, contentMode: .fit)
                                  .foregroundStyle(.blue)
                                  .padding(.trailing, 5)
                            }
                            if(item.earliestPosition.status == "overdue"){ //poster mit nur overdue positoin werden nicht angezeigt, poster mit unter andererm overdue positions -> die overdue position wird ignoriert
                               Image(systemName: "\(item.expiredCount).circle.fill")
                                  .resizable()
                                  .frame(maxWidth: 22, maxHeight: 22)
                                  .aspectRatio(1, contentMode: .fit)
                                  .foregroundStyle(.red)
                            }
                            
                            Spacer()
                         }
                         .contentShape(Rectangle())
                         .onTapGesture {
                            selectedPoster = item.poster
                            isShowingDetails = true
                         }
//                      }
                   }
                }
                .padding(.top, 20)
                .refreshable {
                   Task {
                      await viewModel.fetchPosters()
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
                .padding(.horizontal) .padding(.bottom, 10)
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
//       .onChange(of: searchText) {
//          Task {
//             if searchText.isEmpty {
//                postersFiltered = posters
//             } else {
//                postersFiltered = posters.filter { poster in
//                   return poster.name.contains(searchText)
//                }
//             }
//          }
//       }
    }
}

#Preview {
    PostersView()
}
