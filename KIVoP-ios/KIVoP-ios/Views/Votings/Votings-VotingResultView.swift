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
   var votingResults: GetVotingResultsDTO
   
   
    var body: some View {
       ScrollView {
          VStack {
             Divider()
             
             PieChartView(voting: voting, votingResults: votingResults)
             .padding()
             
             Divider()
             
             HStack {
                Image(systemName: "person.bust.fill")
                Text(getMeetingName(voting: voting))
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
       }
    }
   
   func getColor (index: UInt8) -> Color {
      return colorMapping[index] ?? .gray
   }
   
   func getMeetingName(voting: GetVotingDTO) -> String {
      // API call
      return votingsView.getMeeting(meetingID: voting.meetingId).name
   }

}

#Preview() {
   var votingsView: VotingsView = .init()
   
   Votings_VotingResultView(votingsView: VotingsView(), voting: votingsView.mockVotings[1], votingResults: votingsView.mockVotingResults)
}
