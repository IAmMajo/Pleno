//
//  Votings-VotingsOverview.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 08.11.24.
//

import SwiftUI

// SampleData

struct Voting: Identifiable, Hashable {
   let id = UUID()
   var title: String
   var startet_at: Date
   var meeting: Meeting
   var is_open: Bool
}

struct Meeting: Identifiable, Hashable {
   let id = UUID()
   var title: String
   var start: Date
   var status: status
}

enum status: String, Codable {
   case scheduled
   case inSession
   case completed
}


struct Votings_VotingsOverview: View {

   //Sample Data
   
   let sampleMeetings = [
      Meeting(title: "Sitzung", start: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, status: .inSession),
      Meeting(title: "Sitzung2", start: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, status: .completed)
   ]
   
   var _dateComponents1: DateComponents {
      var dateComponents1 = DateComponents()
      dateComponents1.day = -7
      dateComponents1.minute = -15
      return dateComponents1
   }
   
   var _dateComponents2: DateComponents {
      var dateComponents2 = DateComponents()
      dateComponents2.day = -7
      dateComponents2.minute = -15
      return dateComponents2
   }
   
   var sampleVotings: [Voting] {
      return [
         Voting(title: "Vereinsfarbe", startet_at: Date.now, meeting: sampleMeetings[0], is_open: true),
            Voting(title: "Abstimmung5", startet_at: Calendar.current.date(byAdding: _dateComponents1, to: Date())!, meeting: sampleMeetings[1], is_open: false),
            Voting(title: "Abstimmung3", startet_at: Calendar.current.date(byAdding: .minute, value: -35, to: Date())!, meeting: sampleMeetings[0], is_open: false),
            Voting(title: "Abstimmung4", startet_at: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, meeting: sampleMeetings[1], is_open: false),
            Voting(title: "Abstimmung2", startet_at: Calendar.current.date(byAdding: .minute, value: -15, to: Date())!, meeting: sampleMeetings[0], is_open: false),
            Voting(title: "Abstimmung6", startet_at: Calendar.current.date(byAdding: _dateComponents2, to: Date())!, meeting: sampleMeetings[1], is_open: false)
         ]
   }
   
   ///////////////////////////////////////////////////////////////////////
   
   @State private var searchText = ""

   var votingsOfMeetings: [[Voting]] {
      var votingsByMeeting: [UUID: [Voting]] = [:]
      
      for voting in sampleVotings {
         let meetingID = voting.meeting.id
         if votingsByMeeting[meetingID] == nil {
            votingsByMeeting[meetingID] = []
         }
         votingsByMeeting[meetingID]?.append(voting)
      }
   
      var votingsOfMeetingsSorted: [[Voting]] = Array(votingsByMeeting.values)
      
      votingsOfMeetingsSorted = votingsOfMeetingsSorted.map { $0.sorted { $0.startet_at > $1.startet_at } }

      votingsOfMeetingsSorted.sort {
              guard let firstVotingInGroup1 = $0.first, let firstVotingInGroup2 = $1.first else {
                  return false
              }
              return firstVotingInGroup1.meeting.start > firstVotingInGroup2.meeting.start
          }
      
      return votingsOfMeetingsSorted
   }
   
   var meetingTitle: String {
      if (votingsOfMeetings.first?.first?.meeting.status == .inSession) {
         return "Aktuelle Sitzung"
      } else {
         return votingsOfMeetings.first?.first?.meeting.title ?? ""
      }
   }
   
   func getMeetingTitle(votingGroup: [Voting]) -> String {
      if (votingGroup.first?.meeting.status == .inSession) {
         return "Aktuelle Sitzung"
      } else {
         return "\(votingGroup.first?.meeting.title ?? "") - \(DateTimeFormatter.formatDate(votingGroup.first?.meeting.start ?? Date()))"
      }
   }
   
   func voteCastedSymbolColor (voting: Voting) -> Color {
      if (false) { // has user voted
         return .blue
      } else {
         return voting.is_open ? .orange : .blue  //.red
      }
   }
   
   func voteCastedStatus (voting: Voting) -> String {
      if (false) { // has user voted
         return "checkmark"
      } else {
         return voting.is_open ? "exclamationmark.arrow.trianglehead.counterclockwise.rotate.90" : "checkmark" //"xmark"
      }
   }
   
   
   var body: some View {
      ZStack {
         Group {
            if !votingsOfMeetings.isEmpty {
               List {
                  ForEach(votingsOfMeetings, id: \.self) { votingGroup in
                     Section(header: Text(getMeetingTitle(votingGroup: votingGroup))) {
                        ForEach(votingGroup, id: \.self) { voting in
                           
                           NavigationLink(destination: VotingDetail()) {
                              HStack {
                                 Text(voting.title)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                 Spacer()
                                 Image(systemName: "\(voteCastedStatus(voting: voting))")
                                    .foregroundStyle(voteCastedSymbolColor(voting: voting))
                                 Spacer()
                              }
                           }
                        }
                     }
                  }
               }
               
            } else {
               ContentUnavailableView {
                  Label("Keine Abstimmungen gefunden", systemImage: "document")
               }
            }
         }
         .navigationTitle("Abstimmungen")
         .navigationBarTitleDisplayMode(.large)
      }
      .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Suchen")
      //      .onChange(of: $searchText) {}
   }
}

#Preview {
   NavigationStack {
      Votings_VotingsOverview()
         .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
               Button {
               } label: {
                  HStack {
                     Image(systemName: "chevron.backward")
                     Text("Back")
                  }
               }
            }
         }
   }
}

