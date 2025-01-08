//
//  Votings-VotingResultView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 15.11.24.
//

import SwiftUI
import LocalAuthentication
import MeetingServiceDTOs

struct Votings_VotingResultView: View {
   @StateObject private var webSocketService = WebSocketService()
   @StateObject private var meetingViewModel = MeetingViewModel()

   let votingsView: VotingsView
   
   let voting: GetVotingDTO
   @State var votingResults: GetVotingResultsDTO
   @State var meetingName = ""
   
   @State private var isLoading = false
   @State private var error: String?
   @State private var resultsLoaded: Bool = false
   @State private var isLiveStatusAvailable: Bool = false
   
   @State var optionTextMap: [UInt8: String] = [:]
   
    var body: some View {
       ScrollView {
          if (isLiveStatusAvailable || resultsLoaded) {
             VStack {
                ZStack {
                   if isLiveStatusAvailable {
                      VotingLiveStatusView(votingId: voting.id) {
                         // Handle WebSocket error
                         Task {
                            self.isLiveStatusAvailable = false
                            await loadVotingResults(voting: voting)
                         }
                      }
                         .padding()
                   } else {
                      PieChartView(optionTextMap: optionTextMap, votingResults: votingResults)
                         .padding()
                   }
                }
//                .padding(-5)
                .background(Color(UIColor.systemBackground))
                .padding(.bottom, 10)
                
                Text(voting.question)
                   .frame(maxWidth: .infinity, alignment: .leading)
                   .padding(.leading).padding(.trailing)
                   .font(.title2)
                   .fontWeight(.bold)
                
                LazyVStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "person.bust.fill")
                            Text(meetingName)
                        }
                        .foregroundStyle(Color(UIColor.label).opacity(0.6))
                        
                        Text(voting.description)
                            .fixedSize(horizontal: false, vertical: true) // Allow multi-line text
                    }
                .padding(.horizontal)
                
//                List {
//                    Section {
////                       VStack {
//                          HStack {
//                             Image(systemName: "person.bust.fill")
//                             Text(meetingName)
//                          }
//                          .foregroundStyle(Color(UIColor.label).opacity(0.6))
//                          
////                       }
//                       HStack {
//                          Text(voting.description)
////                             .fixedSize(horizontal: false, vertical: true) // Allow dynamic height
//                       }
//                    } header: {
//                       Spacer(minLength: 0).listRowInsets(EdgeInsets())
//                    }
//                }
//                .scrollDisabled(true)
//                .frame(height: CGFloat((voting.description.count * 2) + (votingResults.results.count < 4 ? 200 : 0)), alignment: .top)
//                .environment(\.defaultMinListHeaderHeight, 10)
                
//                HStack {
//                   Image(systemName: "person.bust.fill")
//                   Text(meetingName)
//                      .frame(maxWidth: .infinity, alignment: .leading)
//                }
//                .foregroundStyle(Color(UIColor.label).opacity(0.6))
//                .padding(.leading).padding(.top, 1)
//                
//                Divider()
//                Text(voting.description)
//                   .frame(maxWidth: .infinity, alignment: .leading)
//                   .padding(.leading).padding(.top, 3).padding(.trailing)
                
                if isLiveStatusAvailable {
//                   HStack(alignment: .top) {
//                      Image(systemName: "info.circle.fill")
//                         .padding(.top, 1)
//                      Text("Die Abstimmung läuft noch. Du hast bereits abgestimmt.")
//                   }
//                   .padding()
//                   .foregroundStyle(Color(UIColor.label).opacity(0.6))
//                   .background(Color(UIColor.systemBackground))
//                   .cornerRadius(10)
//                   .padding(.top, 20) .padding(.leading, 2) .padding(.trailing, 2)
                   
                   List {
                       Section {
                           HStack(alignment: .top) {
                               Image(systemName: "info.circle.fill")
                                   .padding(.top, 1)
                               Text("Die Abstimmung läuft noch. Du hast bereits abgestimmt.")
                           }
                           .foregroundStyle(Color(UIColor.label).opacity(0.6))
                           .background(Color(UIColor.systemBackground))
                           .cornerRadius(10)
                       } header: {
                          Spacer(minLength: 0).listRowInsets(EdgeInsets())
                       }
                   }
                   .frame(height: 100, alignment: .top)
                   .environment(\.defaultMinListHeaderHeight, 10)

                      
                } else {
                   List{
                      Section {
                         ForEach (votingResults.results, id: \.self) { result in
                            HStack {
                               Image(systemName: votingResults.myVote == result.index ? "checkmark.circle.fill" : "circle.fill")
                                  .foregroundStyle(getColor(index: result.index))
                               Text(optionTextMap[result.index] ?? "")
                               Spacer()
                               Text("\(result.percentage, specifier: "%.2f")%")
                                  .opacity(0.6)
                            }
                         }
                      } header: {
                         Spacer(minLength: 0).listRowInsets(EdgeInsets())
                      }
                   }
                   .frame(height: CGFloat((votingResults.results.count * 65) + (votingResults.results.count < 4 ? 200 : 0)), alignment: .top)
                   //             .scrollContentBackground(.hidden)
                   .environment(\.defaultMinListHeaderHeight, 10)
                }
             }
          } else {
             ContentUnavailableView(
               "Die Abstimmungsergebnisse konnten nicht geladen werden",
               systemImage: "chart.pie.fill"
//               description: Text("Du hast bereits abgestimmt. In Zukunft werden hier die Live-Ergebnisse einer offenen Abstimmung angezeigt.")
             )
          }
       }
       .refreshable {
          self.isLiveStatusAvailable = await isLiveStatusAvailable(votingId: voting.id)
          if !isLiveStatusAvailable {
             await loadVotingResults(voting: voting)
          }
       }
       .navigationTitle(isLiveStatusAvailable ? "Live-Status" : "Abstimmungs-Ergebnis")
       .navigationBarTitleDisplayMode(.inline)
       .background(Color(UIColor.secondarySystemBackground))
       .onAppear {
          Task {
             self.isLiveStatusAvailable = await isLiveStatusAvailable(votingId: voting.id)
             if !isLiveStatusAvailable {
                await loadVotingResults(voting: voting)
             }
             await loadMeetingName(voting: voting)
          }
          fillOptionTextMap(voting: voting)
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

   private func loadVotingResults(voting: GetVotingDTO) async {
      VotingService.shared.fetchVotingResults(votingId: voting.id) { result in
         DispatchQueue.main.async {
            switch result {
            case .success(let results):
               self.votingResults = results
               resultsLoaded = true
            case .failure(let error):
               print("Fehler beim Abrufen der Ergebnisse: \(error.localizedDescription)")
            }
         }
      }
   }
   
   private func loadMeetingName(voting: GetVotingDTO) async {
      do {
         let meeting = try await meetingViewModel.fetchMeeting(byId: voting.meetingId)
         meetingName = meeting.name
      } catch {
         print("Error fetching meeting: \(error.localizedDescription)")
      }
   }
   
   func getColor (index: UInt8) -> Color {
      return colorMapping[index] ?? .gray
   }
   
   func fillOptionTextMap(voting: GetVotingDTO) {
      for option in voting.options {
         optionTextMap[option.index] = option.text
      }
      optionTextMap[0] = "Enthaltung"
   }
   
//   func getMeetingName(voting: GetVotingDTO) -> String {
//      return votingsView.getMeeting(meetingID: voting.meetingId).name
//   }

}

#Preview() {
   var votingsView: VotingsView = .init()
   
   Votings_VotingResultView(votingsView: VotingsView(), voting: votingsView.mockVotings[1], votingResults: votingsView.mockVotingResults)
}
