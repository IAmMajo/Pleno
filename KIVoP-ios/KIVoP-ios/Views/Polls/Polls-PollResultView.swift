//
//  Polls-PollResultView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 18.01.25.
//

import SwiftUI
import PollServiceDTOs

struct Polls_PollResultView: View {
   @StateObject private var webSocketService = WebSocketService()

   let poll: GetPollDTO
   @State var pollResults: GetPollResultsDTO
   @State var meetingName = ""
   
   @State private var isLoading = false
   @State private var error: String?
   @State private var resultsLoaded: Bool = false
   @Environment(\.dismiss) var dismiss // Zugriff auf die Navigationsebene
   
   @State var optionTextMap: [UInt8: String] = [:]
   
   init(poll: GetPollDTO) {
      self.poll = poll
      self.pollResults = mockPollResults
   }
   
    var body: some View {
       ScrollView {
          if (true) {
             VStack {
                ZStack {
                   PollPieChartView(optionTextMap: optionTextMap, pollResults: pollResults)
                      .padding(.vertical)
                      .padding(.horizontal)
                }
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
                .padding() .padding(.top, -8)

                HStack {
                   Image(systemName: "calendar.badge.clock")
                   let string = poll.isOpen ? NSLocalizedString("Schließt:", comment: "") : NSLocalizedString("Geschlossen:", comment: "")
                   Text("\(string) \(DateTimeFormatter.formatDate(poll.closedAt)), \(DateTimeFormatter.formatTime(poll.closedAt)) Uhr")
                      .frame(maxWidth: .infinity, alignment: .leading)
                }
                .foregroundStyle(Color(UIColor.secondaryLabel))
                .padding(.leading).padding(.bottom, 1)
                
                Text(poll.question)
                   .font(.title2)
                   .fontWeight(.bold)
                   .frame(maxWidth: .infinity, alignment: .leading)
                   .padding(.leading).padding(.trailing)
                   
               if !poll.description.isEmpty {
                   ZStack {
                      Text(poll.description)
                         .padding()
                         .frame(maxWidth: .infinity, alignment: .leading)
                   }
                   .background(Color(UIColor.systemBackground))
                   .cornerRadius(10)
                   .padding(.horizontal)
                }
                
                if pollResults.totalCount != 0 {
                   PollResultList(results: pollResults, optionTextMap: optionTextMap)
                } else {
                   ZStack {
                      HStack {
                         Image(systemName: "info.circle.fill")
                            .padding(.top, 1)
                         Text("Für diese Umfrage hat keiner abgestimmt.")
                      }
                      .foregroundStyle(Color(UIColor.label).opacity(0.6))
                      .padding()
                      .frame(maxWidth: .infinity, alignment: .leading)
                   }.background(Color(UIColor.systemBackground))
                      .cornerRadius(10)
                      .padding(.horizontal) .padding(.top)
                }

             }
          } else if isLoading {
             ProgressView("Loading...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
          } else {
             ContentUnavailableView(
               "Die Abstimmungsergebnisse konnten nicht geladen werden",
               systemImage: "chart.pie.fill"
             )
          }
       }
       .refreshable {
         fetchPollResults()
       }
       .onAppear {
          Task {
             isLoading = true
             fetchPollResults()
          }
          fillOptionTextMap(poll: poll)
          isLoading = false
       }
       .navigationTitle("Umfrage-Ergebnis")
       .navigationBarTitleDisplayMode(.inline)
       .background(Color(UIColor.secondarySystemBackground))
    }
   

   private func getIdentities(result: GetPollResultDTO) -> [GetIdentityDTO] {
      if let identities = result.identities {
         return identities
      } else {
         return []
      }
   }
   
   private func fetchPollResults() {
      PollAPI.shared.fetchPollResultsById(pollId: poll.id) { result in
         DispatchQueue.main.async {
            switch result {
            case .success(let resultsData):
               self.pollResults = resultsData
               resultsLoaded = true
            case .failure(let error):
               print("Fehler beim Abrufen der Ergebnisse: \(error.localizedDescription)")
            }
         }
      }
   }
   
   func fillOptionTextMap(poll: GetPollDTO) {
      for option in poll.options {
         optionTextMap[option.index] = option.text
      }
      optionTextMap[0] = ""
   }

// für Mock-Daten
//   func getMeetingName(voting: GetVotingDTO) -> String {
//      return votingsView.getMeeting(meetingID: voting.meetingId).name
//   }

}

struct PollResultList: View {
   @Environment(\.colorScheme) var colorScheme
   @State private var isCount = false
   let results: GetPollResultsDTO
   let optionTextMap: [UInt8: String]
   
   func getColor(index: UInt8) -> Color {
      return colorMapping[index] ?? .gray
   }
   
   var body: some View {
      VStack(alignment: .leading, spacing: 7) {
         HStack {
            Text("\(results.totalCount) Stimmen von \(results.identityCount) Personen")
//            Text("Stimmen (\(results.totalCount))")
               .foregroundStyle(Color(UIColor.secondaryLabel))
               .padding(.leading, 32)
            Spacer()
            Toggle(isOn: $isCount) {
            }
            .toggleStyle(ImageToggleStyle())
            .padding(.trailing, 32) .padding(.bottom, 1)
         }
         
         VStack {
            ForEach(results.results, id: \.index) { result in
               PollResultRow(
                  pollResults: results,
                  result: result,
                  optionText: optionTextMap[result.index] ?? "",
                  getColor: getColor,
                  isCount: $isCount
               )
               .padding(.vertical, 6)
               
               if result.id != results.results.last?.id {
                  Divider()
                     .padding(.vertical, 2)
               }
            }
         }
         .padding(.horizontal)
         .padding(.vertical, 12)
         .background(Color(UIColor.systemBackground))
         .cornerRadius(10)
         .padding(.horizontal)
      }
      .padding(.vertical)
   }
}

struct PollResultRow: View {
   @State private var isCollapsed: Bool = true
   let pollResults: GetPollResultsDTO
   let result: GetPollResultDTO
   let optionText: String
   let getColor: (UInt8) -> Color
   @Binding var isCount: Bool
   
   var body: some View {
      VStack {
         HStack {
            Image(systemName: pollResults.myVotes.contains(where: {$0 == result.index})  ? "checkmark.circle.fill" : "circle.fill")
               .foregroundStyle(getColor(result.index))
            Text(optionText)
            Spacer()
            if isCount {
               Text("\(result.count)")
                  .opacity(0.6)
            } else {
               Text("\(result.percentage, specifier: "%.2f")%")
                  .opacity(0.6)
            }
            
            if let identities = result.identities, !identities.isEmpty {
               Image(systemName: isCollapsed ? "chevron.forward" : "chevron.down")
                  .foregroundStyle(.blue)
            }
         }
         .contentShape(Rectangle())
         .onTapGesture {
            if let identities = result.identities, !identities.isEmpty {
               withAnimation(.easeInOut(duration: 0.3)) {
                  isCollapsed.toggle()
               }
            }
         }
         
         if !isCollapsed, let identities = result.identities {
            VStack(alignment: .leading) {
               Divider()
                  .padding(.vertical, 4)
               ForEach(identities, id: \.id) { identity in
                  HStack {
                     Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(getColor(result.index).opacity(0.55).mix(with: .gray, by: 0.1))
                     Text(identity.name)
                  }
                  if identity.id != identities.last?.id {
                     Divider()
                        .padding(.top, 2) .padding(.bottom, 4)
                  }
               }
            }
            .padding(.leading, 25)
            .transition(
               .asymmetric(
                  insertion: .opacity.animation(.easeIn(duration: 0.1)),
                  removal: .opacity.animation(.easeOut(duration: 0.1))
               )
            )
            .animation(.easeInOut(duration: 0.5), value: isCollapsed) // Controls the movement
         }
      }
   }
}

extension GetIdentityDTO: @retroactive Identifiable {}
extension GetIdentityDTO: @retroactive Equatable {}
extension GetIdentityDTO: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    public static func == (lhs: GetIdentityDTO, rhs: GetIdentityDTO) -> Bool {
        return lhs.id == rhs.id
    }
}

#Preview() {
//   Polls_PollResultView(poll: mockPolls[0], onPollEnd:{ _ in})
//      .toolbar {
//         ToolbarItem(placement: .navigationBarLeading) {
//            Button {
//            } label: {
//               HStack {
//                  Image(systemName: "chevron.backward")
//                  Text("Zurück")
//               }
//            }
//         }
//      }
}
