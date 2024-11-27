//
//  Test.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 25.11.24.
//

import SwiftUI
import MeetingServiceDTOs

struct Test: View {
   func test () throws -> String {
      return try JSONEncoder().encode(CreateMeetingDTO(name: "Sitzung 1", description: "Die aller erste Sitzung (zumindest die, die zuerst erstellt wurde)", start: Calendar.current.date(byAdding: .day, value: 30, to: Date())!, duration: 150, location: .init(name: "Veranstaltungsort 1"))).base64EncodedString()
   }
   
    var body: some View {
       Text("\(String(describing: try? test()))")
          .task {
             print(try? test())
          }
       
       //            Button(action: {
       //               Task {
       //                  do {
       //                     // Generate a single UUID for the voting ID
       //                     let votingId = UUID()
       //
       //                     // Prepare options using the same votingId
       //                     let options: [GetVotingOptionDTO] = [
       //                        GetVotingOptionDTO(votingId: votingId, index: 1, text: "Option1"),
       //                        GetVotingOptionDTO(votingId: votingId, index: 2, text: "Option2"),
       //                        GetVotingOptionDTO(votingId: votingId, index: 3, text: "Option3"),
       //                        GetVotingOptionDTO(votingId: votingId, index: 4, text: "Option4")
       //                     ]
       //
       //                     // Create the voting DTO
       //                     let newVoting = CreateVotingDTO(
       //                        meetingId: UUID(uuidString: "0F55CE47-E6CC-4139-893C-55FAC9CB562B")!,
       //                        question: "Welche Option soll gewählt werden? 1",
       //                        description: "Das ist die aller erste Abstimmung",
       //                        anonymous: false,
       //                        options: options
       //                     )
       //
       //                     let jsonEncoder = JSONEncoder()
       //                     jsonEncoder.outputFormatting = .prettyPrinted
       //
       //                     if let jsonData = try? jsonEncoder.encode(newVoting),
       //                        let jsonString = String(data: jsonData, encoding: .utf8) {
       //                        print("Payload being sent: \(jsonString)")
       //                     }
       //
       //                     // Make the API request
       //                     let createdVoting = try await APIService.shared.createVoting(newVoting)
       //
       //                     // Log the result or handle success
       //                     print("Voting created successfully: \(createdVoting)")
       //                  } catch {
       //                     // Handle errors
       //                     print("Error creating voting: \(error)")
       //                  }
       //               }
       //            }) {
       //               Text("Create Voting")
       //                  .font(.headline)
       //                  .foregroundColor(.white)
       //                  .padding()
       //                  .background(Color.blue)
       //                  .cornerRadius(8)
       //            }
       //            .padding()
    }
}

#Preview {
    Test()
}
