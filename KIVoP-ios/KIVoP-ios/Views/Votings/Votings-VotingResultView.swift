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
   let votingsView: VotingsView
   
   let voting: GetVotingDTO
   @State var votingResults: GetVotingResultsDTO
   @State var meetingName = ""
   
   @State private var isLoading = false
   @State private var error: String?
   
   @State private var optionTextMap: [UInt8: String] = [:]
   
    var body: some View {
       ScrollView {
          VStack {
             Divider()
             
             PieChartView(voting: voting, votingResults: votingResults)
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
                         Text(voting.options[Int(result.index)].text)
                         Spacer()
                         Text("\(result.percentage, specifier: "%.2f")%") //mit 1-2 Nachkommastellen?
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
       .navigationBarTitleDisplayMode(.inline)
       .background(Color(UIColor.secondarySystemBackground))
       .onAppear {
//          fillOptionTextMap()
          Task {
             await loadVotingResults(voting: voting)
             await loadMeetingName(voting: voting)
          }
       }
    }
   
   func fillOptionTextMap(voting: GetVotingDTO) {
      for option in voting.options {
         optionTextMap[option.id] = option.text
      }
   }
   
   private func loadVotingResults(voting: GetVotingDTO) async {
      isLoading = true
      error = nil
      do {
         votingResults = try await APIService.shared.fetchVotingResults(by: voting.id)
      } catch {
         self.error = error.localizedDescription
      }
      isLoading = false
   }
   
   private func loadMeetingName(voting: GetVotingDTO) async {
      isLoading = true
      error = nil
      do {
         let meeting = try await APIService.shared.fetchMeeting(by: voting.meetingId)
         meetingName = meeting.name
      } catch {
         self.error = error.localizedDescription
      }
      isLoading = false
   }
   
   func getColor (index: UInt8) -> Color {
      return colorMapping[index] ?? .gray
   }
   
//   func getMeetingName(voting: GetVotingDTO) -> String {
//      return votingsView.getMeeting(meetingID: voting.meetingId).name
//   }

}

#Preview() {
   var votingsView: VotingsView = .init()
   
   Votings_VotingResultView(votingsView: VotingsView(), voting: votingsView.mockVotings[1], votingResults: votingsView.mockVotingResults)
}
