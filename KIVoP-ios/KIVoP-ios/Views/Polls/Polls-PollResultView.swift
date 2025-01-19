//
//  Polls-PollResultView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 18.01.25.
//

import SwiftUI
import MeetingServiceDTOs

struct Polls_PollResultView: View {
   @StateObject private var webSocketService = WebSocketService()

   let poll: Poll
   @State var pollResults: PollResults = mockPollResults
   @State var meetingName = ""
   
   @State private var isLoading = false
   @State private var error: String?
   @State private var resultsLoaded: Bool = false
   @State private var isLiveStatusAvailable: Bool = false
   var onPollEnd: (Poll) -> Void
   @Environment(\.dismiss) var dismiss // Zugriff auf die Navigationsebene
   
   @State var optionTextMap: [UInt8: String] = [:]
   
//   init(poll: Poll) {
//      self.poll = poll
//      self.pollResults = mockPollResults
//      self.onPollEnd = { _ in
//         
//      }
//   }
   
    var body: some View {
       ScrollView {
          if (isLiveStatusAvailable || /*resultsLoaded*/ true) {
             VStack {
                ZStack {
                   if isLiveStatusAvailable {
//                      VotingLiveStatusView(votingId: voting.id) {
//                         // Handle WebSocket error
//                         Task {
//                            self.isLiveStatusAvailable = false
//                            await loadVotingResults(voting: voting)
//                         }
//                      }
//                      .padding(.vertical) .padding(.top, -5)
                   } else {
                      PollPieChartView(optionTextMap: optionTextMap, pollResults: pollResults)
                         .padding(.vertical)
                         .padding(.horizontal)
                   }
                }
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
                .padding() .padding(.top, -8)

                HStack {
                   Image(systemName: "calendar.badge.clock")
                   let string = poll.isOpen ? "Schließt:" : "Geschlossen:"
                   Text("\(string) \(DateTimeFormatter.formatDate(poll.expirationDate)), \(DateTimeFormatter.formatTime(poll.expirationDate)) Uhr")
                      .frame(maxWidth: .infinity, alignment: .leading)
                }
                .foregroundStyle(Color(UIColor.label).opacity(0.6))
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
                
                if isLiveStatusAvailable {
                   ZStack {
                      HStack {
                         Image(systemName: "info.circle.fill")
                            .padding(.top, 1)
                         Text("Die Abstimmung läuft noch. Du hast bereits abgestimmt.")
                      }
                      .foregroundStyle(Color(UIColor.label).opacity(0.6))
                      .padding()
                      .frame(maxWidth: .infinity, alignment: .leading)
                   }.background(Color(UIColor.systemBackground))
                      .cornerRadius(10)
                      .padding(.horizontal) .padding(.top)
                } else {
                   PollResultList(resultData: getResultData(pollResults: pollResults), resultDataCount: pollResults.results.count)
                      .offset(y: -25)
                }
                
                if poll.isOpen {
                   Button {
                      onPollEnd(poll)
                      dismiss() // Ansicht schließen und zurück navigieren
                   } label: {
                      Text("Umfrage beenden")
                         .foregroundStyle(Color(UIColor.systemBackground))
                         .fontWeight(.semibold)
                         .frame(maxWidth: .infinity)
                   }
                   .background(Color.blue)
                   .cornerRadius(10)
                   .padding()
                   .buttonStyle(.bordered)
                   .controlSize(.large)
                   .offset(y: -25)
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
//          self.isLiveStatusAvailable = await isLiveStatusAvailable(votingId: voting.id)
          if !isLiveStatusAvailable {
//             await loadVotingResults(voting: voting)
          }
       }
       .onAppear {
          Task {
             isLoading = true
//             self.isLiveStatusAvailable = await isLiveStatusAvailable(votingId: voting.id)
             if !isLiveStatusAvailable {
//                await loadVotingResults(voting: voting)
             }
          }
          fillOptionTextMap(poll: poll)
          isLoading = false
       }
       .navigationTitle(isLiveStatusAvailable ? "Live-Status" : "Abstimmungs-Ergebnis")
       .navigationBarTitleDisplayMode(.inline)
       .background(Color(UIColor.secondarySystemBackground))
    }
   
   private func getResultData(pollResults: PollResults) -> [ResultData] {
      var resultDatas: [ResultData] = []
      
      for result in pollResults.results {
         var resultIdentities: [ResultData] = []
         for identity in getIdentities(result: result) {
            resultIdentities.append(ResultData(
                  icon: "checkmark.circle.fill",
                  color: getColor(index: result.index).opacity(0.5).mix(with: .gray, by: 0.3),
                  name: identity.name,
                  percentage: nil
               ))
         }
         resultDatas.append(ResultData(
            icon: pollResults.myVote == result.index ? "checkmark.circle.fill" : "circle.fill",
            color: getColor(index: result.index),
            name: optionTextMap[result.index] ?? "",
            percentage: Double(result.count),
            identities: resultIdentities
         ))
      }
      return resultDatas
   }
   
   private func getIdentities(result: PollResult) -> [GetIdentityDTO] {
      if let identities = result.identities {
         return identities
      } else {
         return []
      }
   }
   
   private func isLiveStatusAvailable(votingId: UUID) async -> Bool {
      await withCheckedContinuation { continuation in
         webSocketService.connect(to: votingId)
         // Wait for the WebSocket to receive messages
         DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let liveStatus = webSocketService.liveStatus, !liveStatus.isEmpty {
               webSocketService.disconnect()
               continuation.resume(returning: true)
            } else if webSocketService.votingResults != nil {
               webSocketService.disconnect()
               continuation.resume(returning: false)
            } else if webSocketService.errorMessage != nil {
               webSocketService.disconnect()
               continuation.resume(returning: false)
            } else {
               webSocketService.disconnect()
               continuation.resume(returning: false)
            }
         }
      }
   }

//   private func loadVotingResults(voting: GetVotingDTO) async {
//      VotingService.shared.fetchVotingResults(votingId: voting.id) { result in
//         DispatchQueue.main.async {
//            switch result {
//            case .success(let results):
//               self.votingResults = results
//               resultsLoaded = true
//            case .failure(let error):
//               print("Fehler beim Abrufen der Ergebnisse: \(error.localizedDescription)")
//            }
//         }
//      }
//   }
   
//   private func loadMeetingName(voting: GetVotingDTO) async {
//      do {
//         let meeting = try await meetingViewModel.fetchMeeting(byId: voting.meetingId)
//         meetingName = meeting.name
//      } catch {
//         print("Error fetching meeting: \(error.localizedDescription)")
//      }
//   }
   
   func getColor (index: UInt8) -> Color {
      return colorMapping[index] ?? .gray
   }
   
   func fillOptionTextMap(poll: Poll) {
      for option in poll.options {
         optionTextMap[option.index] = option.text
      }
      optionTextMap[0] = "Enthaltung"
   }

// für Mock-Daten
//   func getMeetingName(voting: GetVotingDTO) -> String {
//      return votingsView.getMeeting(meetingID: voting.meetingId).name
//   }

}

struct PollResultList: View {
   let resultData: [ResultData]
   let resultDataCount: Int
   
   var body: some View {
      List(resultData, children: \.identities) { resultData in
         HStack {
            Image(systemName: resultData.icon)
               .foregroundStyle(resultData.color)
            Text(resultData.name)
            Spacer()
            if let percentage = resultData.percentage {
               Text("\(Int(percentage)) Stimmen")
                  .opacity(0.6)
            }
         }
      }
      .scrollDisabled(true)
//      .frame(height: CGFloat((resultDataCount * 65) + (resultDataCount < 4 ? 200 : 0)), alignment: .top)
      .frame(height: CGFloat((resultDataCount * 55) + (resultDataCount < 4 ? 200 : 0)), alignment: .top)
      .scrollContentBackground(.hidden)
   }
}

#Preview() {
   Polls_PollResultView(poll: mockPolls[0], onPollEnd:{ _ in})
      .toolbar {
         ToolbarItem(placement: .navigationBarLeading) {
            Button {
            } label: {
               HStack {
                  Image(systemName: "chevron.backward")
                  Text("Zurück")
               }
            }
         }
      }
}
