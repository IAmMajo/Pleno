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
   @Environment(\.colorScheme) var colorScheme
   @StateObject private var webSocketService = WebSocketService()
   @StateObject private var meetingViewModel = MeetingViewModel()
   
   let voting: GetVotingDTO
   @State var votingResults: GetVotingResultsDTO
   @State var meetingName = ""
   
   @State private var isLoading = false
   @State private var error: String?
   @State private var resultsLoaded: Bool = false
   @State private var isLiveStatusAvailable: Bool = false
   
   @State var optionTextMap: [UInt8: String] = [:]
   
   init(voting: GetVotingDTO) {
      self.voting = voting
      self.votingResults = mockVotingResults
   }
   
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
                      .padding(.vertical) .padding(.top, -5)
                   } else {
                      PieChartView(optionTextMap: optionTextMap, votingResults: votingResults)
                         .padding(.vertical)
                         .padding(.horizontal)
                   }
                }
                .background(Color(UIColor.systemBackground))
                .cornerRadius(10)
                .padding() .padding(.top, -8)

                HStack {
                   Image(systemName: "person.bust.fill")
                   Text(meetingName)
//                   Text("Sitzungsname")
                      .frame(maxWidth: .infinity, alignment: .leading)
                }
                .foregroundStyle(Color(UIColor.label).opacity(0.6))
                .padding(.leading).padding(.bottom, 1)
                
                Text(voting.question)
                   .font(.title2)
                   .fontWeight(.bold)
                   .frame(maxWidth: .infinity, alignment: .leading)
                   .padding(.leading).padding(.trailing)
                   
                if !voting.description.isEmpty {
                   ZStack {
                      Text(voting.description)
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
//                   ResultList(resultData: getResultData(votingResults: votingResults), resultDataCount: votingResults.results.count)
//                      .offset(y: -25)
                   VotingResultList(results: votingResults, optionTextMap: optionTextMap)
//                   List{
//                      Section {
//                         ForEach (votingResults.results, id: \.self) { result in
//                            ...
//                      } header: {
//                         Spacer(minLength: 0).listRowInsets(EdgeInsets())
//                      }
//                   }
//                   .frame(height: CGFloat((votingResults.results.count * 65) + (votingResults.results.count < 4 ? 200 : 0)), alignment: .top)
//                   //             .scrollContentBackground(.hidden)
//                   .environment(\.defaultMinListHeaderHeight, 10)
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
          self.isLiveStatusAvailable = await isLiveStatusAvailable(votingId: voting.id)
          if !isLiveStatusAvailable {
             await loadVotingResults(voting: voting)
          }
       }
       .onAppear {
          Task {
             isLoading = true
             self.isLiveStatusAvailable = await isLiveStatusAvailable(votingId: voting.id)
             if !isLiveStatusAvailable {
                await loadVotingResults(voting: voting)
             }
             await loadMeetingName(voting: voting)
          }
          fillOptionTextMap(voting: voting)
          isLoading = false
       }
       .navigationTitle(isLiveStatusAvailable ? "Live-Status" : "Abstimmungs-Ergebnis")
       .navigationBarTitleDisplayMode(.inline)
       .background(Color(UIColor.secondarySystemBackground))
    }
   
   private func getResultData(votingResults: GetVotingResultsDTO) -> [ResultData] {
      var resultDatas: [ResultData] = []
      
      for result in votingResults.results {
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
            icon: votingResults.myVote == result.index ? "checkmark.circle.fill" : "circle.fill",
            color: getColor(index: result.index),
            name: optionTextMap[result.index] ?? "",
            percentage: result.percentage,
            identities: resultIdentities
         ))
      }
      return resultDatas
   }
   
   private func getIdentities(result: GetVotingResultDTO) -> [GetIdentityDTO] {
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

// für Mock-Daten
//   func getMeetingName(voting: GetVotingDTO) -> String {
//      return votingsView.getMeeting(meetingID: voting.meetingId).name
//   }

}

struct VotingResultList: View {
   @Environment(\.colorScheme) var colorScheme
   let results: GetVotingResultsDTO
   let optionTextMap: [UInt8: String]
   
   func getColor (index: UInt8) -> Color {
      return colorMapping[index] ?? .gray
   }
   
   var body: some View {
      VStack (alignment: .leading, spacing: 6) {
         Text("STIMMEN (\(results.totalCount))")
            .font(.footnote)
            .foregroundStyle(Color(UIColor.secondaryLabel))
            .padding(.leading, 32)
         ZStack {
            VStack {
               ForEach (results.results, id: \.id) { result in
                  HStack {
                     Image(systemName: results.myVote == result.index ? "checkmark.circle.fill" : "circle.fill")
                        .foregroundStyle(getColor(index: result.index))
                     Text(optionTextMap[result.index] ?? "")
                     Spacer()
                     Text("\(result.percentage, specifier: "%.2f")%")
                        .opacity(0.6)
                  }
                  if result.id != results.results.last?.id {
                     Divider()
                        .padding(.vertical, 2)
                  }
               }
            }
            .padding(.horizontal) .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
         }
         .background(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
         .cornerRadius(10)
         .padding(.horizontal)
      }
      .padding(.vertical)
   }
   
}

struct ResultData: Identifiable {
   let id = UUID()
   let icon: String
   let color: Color
   let name: String
   let percentage: Double?
   var identities: [ResultData]?
}

struct ResultList: View {
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
               Text("\(percentage, specifier: "%.2f")%")
                  .opacity(0.6)
            }
         }
      }
      .frame(height: CGFloat((resultDataCount * 65) + (resultDataCount < 4 ? 200 : 0)), alignment: .top)
      .scrollContentBackground(.hidden)
   }
}

#Preview() {
   Votings_VotingResultView(voting: mockVotings[0])
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
