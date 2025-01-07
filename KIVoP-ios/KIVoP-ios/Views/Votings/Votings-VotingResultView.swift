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
   @StateObject private var meetingViewModel = MeetingViewModel()

   let votingsView: VotingsView
   
   let voting: GetVotingDTO
   @State var votingResults: GetVotingResultsDTO
   @State var meetingName = ""
   
   @State private var isLoading = false
   @State private var error: String?
   @State private var resultsLoaded: Bool = false
   
   @State var optionTextMap: [UInt8: String] = [:]
   
    var body: some View {
       ScrollView {
          if resultsLoaded {
             VStack {
                Divider()
                
                PieChartView(optionTextMap: optionTextMap, votingResults: votingResults)
                   .padding()
                
                Divider()
                
                HStack {
                   Image(systemName: "person.bust.fill")
                   Text(meetingName)
                      .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.leading)
                Text(voting.question)
                   .frame(maxWidth: .infinity, alignment: .leading)
                   .padding(.leading).padding(.top, 2).padding(.trailing)
                   .font(.title2)
                   .fontWeight(.medium)
                Divider()
                Text(voting.description)
                   .frame(maxWidth: .infinity, alignment: .leading)
                   .padding(.leading).padding(.top, 2).padding(.trailing)
                
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
          } else {
//             VotingLiveStatusView(votingId: voting.id)
             ContentUnavailableView(
               "Die Abstimmung läuft noch",
               systemImage: "chart.pie.fill",
               description: Text("Du hast bereits abgestimmt. In Zukunft werden hier die Live-Ergebnisse einer offenen Abstimmung angezeigt.")
             )
          }
       }
       .refreshable {
          await loadVotingResults(voting: voting)
       }
       .navigationBarTitleDisplayMode(.inline)
       .background(Color(UIColor.secondarySystemBackground))
       .onAppear {
          Task {
             await loadVotingResults(voting: voting)
             await loadMeetingName(voting: voting)
          }
          fillOptionTextMap(voting: voting)
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
