//
//  Votings-VotingsOverview.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 08.11.24.
//

import SwiftUI

// SampleData
struct Identity: Identifiable, Hashable {
   let id = UUID()
   var name: String
   
   var votes: [Vote]
}

struct Voting: Identifiable, Hashable {
   let id = UUID()
   var title: String
   var question: String
   var startet_at: Date
   var is_open: Bool
   
   var meeting: MeetingTest
   //var meetingID: UUID
   
   var voting_options: [Voting_option]
//   var votes: [Vote]
}

struct Vote: Identifiable, Hashable {
//   var id: String { "\(votingID.uuidString)-\(identityID.uuidString)" }
   var id = UUID()
   var voting: Voting
//   var identityID: UUID
   var index: UInt8
}

struct Voting_option: Identifiable, Hashable {
   var id = UUID()
//   var id: String { "\(votingID.uuidString)-\(index)" }
//
//   var voting: Voting
   var index: UInt8
   var text: String
   var count: Int?
}

struct MeetingTest: Identifiable, Hashable {
   let id = UUID()
   var title: String
   var start: Date
   var status: status
   
   //var votings: [Voting]
}

enum status: String, Codable {
   case scheduled
   case inSession
   case completed
}


struct Votings: View {
 
   let sampleMeetings = [
      MeetingTest(title: "Jahreshauptversammlung", start: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, status: .inSession),
      MeetingTest(title: "Sitzung2", start: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, status: .completed)
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
   
   var votingGroup: [Voting] {
      return [Voting(title: "Vereinsfarbe", question: "Welche Farbe soll die neue Vereinsfarbe werden?", startet_at: Date.now, is_open: true, meeting: sampleMeetings[0], voting_options: options1),]
   }

   var sampleVotings: [Voting] {
      return [
         Voting(title: "Vereinsfarbe", question: "Welche Farbe soll die neue Vereinsfarbe werden?", startet_at: Date.now, is_open: true, meeting: sampleMeetings[0], voting_options: options1),
         Voting(title: "Abstimmung5", question: "Welche Option soll gewählt werden 5?", startet_at: Calendar.current.date(byAdding: _dateComponents1, to: Date())!, is_open: false, meeting: sampleMeetings[1], voting_options: options2),
         Voting(title: "Abstimmung3", question: "Welche Option soll gewählt werden 3?", startet_at: Calendar.current.date(byAdding: .minute, value: -35, to: Date())!, is_open: false, meeting: sampleMeetings[0], voting_options: options2),
         Voting(title: "Abstimmung4", question: "Welche Option soll gewählt werden 4?", startet_at: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, is_open: false, meeting: sampleMeetings[1], voting_options: options2),
         Voting(title: "Abstimmung2", question: "Welche Option soll gewählt werden 2?", startet_at: Calendar.current.date(byAdding: .minute, value: -15, to: Date())!, is_open: false, meeting: sampleMeetings[0], voting_options: options2),
         Voting(title: "Abstimmung6", question: "Welche Option soll gewählt werden 6?", startet_at: Calendar.current.date(byAdding: _dateComponents2, to: Date())!, is_open: false, meeting: sampleMeetings[1], voting_options: options2)
         ]
   }
   
   var options1: [Voting_option] = [
        Voting_option(index: 0, text: "Enthaltung", count: 10),
        Voting_option(index: 1, text: "Rot", count: 10),
        Voting_option(index: 2, text: "Grün", count: 30),
        Voting_option(index: 3, text: "Blau", count: 50),
   ]
   
   
   var options2: [Voting_option] = [
      Voting_option(index: 0, text: "Enthaltung", count: 4),
      Voting_option(index: 1, text: "Option1", count: 10),
      Voting_option(index: 2, text: "Option2", count: 15),
      Voting_option(index: 3, text: "Option3", count: 30),
      Voting_option(index: 4, text: "Option4", count: 8),
   ]
   
   var sampleIdentity: Identity {
      return Identity(name: "Max Mustermann", votes: [Vote(voting: sampleVotings[4], index: 2), Vote(voting: sampleVotings[2], index: 0)])
   }
   
   ///////////////////////////////////////////////////////////////////////
   
//   @State private var navPath: [String] = []
//   @State var isActive : Bool = false
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
   
   
   var body: some View {
      ZStack {
         //         NavigationStack(path: $navPath) {
         NavigationView {
            if !votingsOfMeetings.isEmpty {
               List {
                  ForEach(votingsOfMeetings, id: \.self) { votingGroup in
                     Votings_VotingsSectionView(votingGroup: votingGroup, sampleIdentity: sampleIdentity)
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
      //.onChange(of: $searchText) {
      //    Task {
      //        if searchText == "" {
      //           await sampleVotings
      //        }
      //
      //        sampleVotings = sampleVotings.filter { voting in
      //            return voting.title.starts(with: searchText)
      //        }
      //    }
      // }
      
   }
}

#Preview {
   NavigationStack {
      Votings()
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
}

