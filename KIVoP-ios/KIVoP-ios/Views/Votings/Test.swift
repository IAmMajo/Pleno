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
    }
}

#Preview {
    Test()
}
