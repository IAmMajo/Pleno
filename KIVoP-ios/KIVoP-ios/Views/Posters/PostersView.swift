//
//  PostersView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 09.12.24.
//

import SwiftUI

struct PostersView: View {
   @Environment(\.dismiss) var dismiss
   
   @State private var posters: [Poster] = mockPosters
   @State private var postersFiltered: [Poster] = []
   
   @StateObject private var postersViewModel = PostersViewModel()
   
   @State private var isLoading = false
   @State private var error: String?
   
   @State private var searchText = ""
   
   let numberOfPostersToHang = [1, 0, 4]
   
//   Calendar.current.isDateInTomorrow(yourDate)
   
   func getDateColor(status: Status) -> Color {
      switch status {
      case .hung:
         return Color(UIColor.secondaryLabel)
      case .takenDown:
         return Color(UIColor.secondaryLabel)
      case .notDisplayed:
         return Color(UIColor.secondaryLabel)
      case .expiresInOneDay:
         return .orange
      case .expired:
         return .red
      }
   }
   
    var body: some View {
       ZStack {
          ZStack(alignment: .top) {
             if !posters.isEmpty {
                
                List {
                   ForEach(postersViewModel.filteredPosters.indices, id: \.self) { index in
                      let poster = postersViewModel.filteredPosters[index]
                      NavigationLink(destination: Posters_PosterDetailView(poster: poster).navigationTitle(poster.name)) {
                         HStack {
                            VStack {
                               Text(poster.name)
                                  .frame(maxWidth: .infinity, alignment: .leading)
                               if let expirationPosition = postersViewModel.posterExpiresPositions[poster.id!] {
                                  Text("\(DateTimeFormatter.formatDate(expirationPosition.expiresAt))")
                                     .frame(maxWidth: .infinity, alignment: .leading)
                                     .font(.callout)
                                     .foregroundStyle(getDateColor(status: expirationPosition.status))
                               } else {
                                  Text("No expiration date")
                                     .frame(maxWidth: .infinity, alignment: .leading)
                                     .font(.callout)
                               }
                            }
                            Spacer()
                            if(postersViewModel.posterExpiresPositions[poster.id!]?.status != .notDisplayed){
                               if (numberOfPostersToHang[index] != 0) {
                                  Image(systemName: "\(numberOfPostersToHang[index]).circle.fill")
                                     .resizable()
                                     .frame(maxWidth: 22, maxHeight: 22)
                                     .aspectRatio(1, contentMode: .fit)
                                     .foregroundStyle(.blue)
                                     .padding(.trailing, 5)
                               }
                            }
                            if(postersViewModel.posterExpiresPositions[poster.id!]?.status == .expired){
                               Image(systemName: "2.circle.fill")
                                  .resizable()
                                  .frame(maxWidth: 22, maxHeight: 22)
                                  .aspectRatio(1, contentMode: .fit)
                                  .foregroundStyle(.red)
                            }
                            
                            Spacer()
                         }
                      }
                   }
                }
                .padding(.top, 20)
                .refreshable {
                }
                
                Picker("Termine", selection: $postersViewModel.selectedTab) {
                    Text("Aktuell").tag(0)
                    Text("Archiviert").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal) .padding(.bottom, 10)
                .background(Color(UIColor.systemBackground))
                
             } else {
                ContentUnavailableView {
                }
             }
             
          }
          .navigationTitle("Plakate")
          .navigationBarTitleDisplayMode(.large)
          
 //         .task(id: selectedVoting) {
 //            if let voting = selectedVoting {
 //               hasVoted = VotingStateTracker.hasVoted(for: voting.id)
 //               await loadVotingResults(voting: voting)
 //            }
 //         }
          .onAppear {
             Task {
                
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
       .onChange(of: searchText) {
          Task {
             if searchText.isEmpty {
                postersFiltered = posters
             } else {
                postersFiltered = posters.filter { poster in
                   return poster.name.contains(searchText)
                }
             }
          }
       }
    }
}

#Preview {
    PostersView()
}
