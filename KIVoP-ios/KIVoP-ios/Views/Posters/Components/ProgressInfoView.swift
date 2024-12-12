//
//  ProgressInfoView.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 11.12.24.
//

import SwiftUI

struct ProgressInfoView: View {
   let status: Status
   
   func getDateProgressText(status: Status) -> String {
      switch status {
      case .hung:
         return "hängt"
      case .takenDown:
         return "abgehangen"
      case .notDisplayed:
         return "hängt noch nicht"
      case .expiresInOneDay:
         return "hängt"
      case .expired:
         return "hängt"
      }
   }
   
   var value: CGFloat {
      switch status {
      case .hung:
         return 90
      case .takenDown:
         return 130
      case .notDisplayed:
         return 160
      case .expiresInOneDay:
         return 90
      case .expired:
         return 90
      }
   }
   
    var body: some View {
       Rectangle()
           .fill(.black.opacity(0.0))
           .frame(width: value, height: 22)
           .overlay( // border as an overlay
             RoundedRectangle(cornerRadius: 10)
                .stroke(.black, lineWidth: 1)
                .overlay(Text("Plakat \(getDateProgressText(status: status))").font(.footnote))
           )
           .cornerRadius(10)
    }
}

#Preview {
   ProgressInfoView(status: Status.hung)
}
