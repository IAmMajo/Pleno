// This file is licensed under the MIT-0 License.
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
                .foregroundStyle(Color(UIColor.secondaryLabel))
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
                } else if votingResults.totalCount != 0 {
                   VotingResultList(results: votingResults, optionTextMap: optionTextMap)
                } else {
                   ZStack {
                      HStack {
                         Image(systemName: "info.circle.fill")
                            .padding(.top, 1)
                         Text("Für diese Abstimmung hat keiner abgestimmt.")
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
   @State private var isCount = false
   let results: GetVotingResultsDTO
   let optionTextMap: [UInt8: String]
   
   func getColor(index: UInt8) -> Color {
      return colorMapping[index] ?? .gray
   }
   
   var body: some View {
      VStack(alignment: .leading, spacing: 7) {
         HStack {
            Text("Stimmen (\(results.totalCount))")
               .foregroundStyle(Color(UIColor.secondaryLabel))
               .padding(.leading, 32)
            Spacer()
            Toggle(isOn: $isCount) {
            }
            .toggleStyle(ImageToggleStyle())
            .padding(.trailing, 32) .padding(.bottom, 1)
         }
         
         VStack {
            ForEach(results.results, id: \.id) { result in
               VotingResultRow(
                  votingResults: results,
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

struct VotingResultRow: View {
   @State private var isCollapsed: Bool = true
   let votingResults: GetVotingResultsDTO
   let result: GetVotingResultDTO
   let optionText: String
   let getColor: (UInt8) -> Color
   @Binding var isCount: Bool
   
   var body: some View {
      VStack {
         HStack {
            Image(systemName: votingResults.myVote == result.index ? "checkmark.circle.fill" : "circle.fill")
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

struct ImageToggleStyle: ToggleStyle {
   var percentImage = "percent"
   var countImage = "numbers"
   
   func makeBody(configuration: Configuration) -> some View {
      HStack {
         RoundedRectangle(cornerRadius: 28)
            .fill(configuration.isOn ? Color(.systemGray3).mix(with: .blue, by: 0.4) : Color(.systemGray3).mix(with: .blue, by: 0.4))
            .overlay {
               Circle()
                  .fill(.white)
                  .padding(3)
                  .overlay {
                     Image(systemName: configuration.isOn ? countImage : percentImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12)
                        .foregroundColor(configuration.isOn ? Color(.systemGray5).mix(with: .blue, by: 0.8) : Color(.systemGray4).mix(with: .blue, by: 0.5))
                  }
                  .offset(x: configuration.isOn ? 10 : -10)
            }
            .frame(width: 42, height: 26)
            .onTapGesture {
               withAnimation(.spring()) {
                  configuration.isOn.toggle()
               }
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
